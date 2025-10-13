import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:salas_beats/services/connectivity_service.dart';
import 'package:salas_beats/utils/exceptions.dart';

/// Servicio HTTP mejorado con manejo de conectividad y timeouts optimizados
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal() {
    _initializeDio();
  }

  late Dio _dio;
  final ConnectivityService _connectivityService = ConnectivityService();

  Dio get dio => _dio;

  /// Inicializa Dio con configuraciones optimizadas
  void _initializeDio() {
    _dio = Dio();
    
    // Configuraciones base
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 15), // Timeout de conexión
      receiveTimeout: const Duration(seconds: 30), // Timeout de recepción
      sendTimeout: const Duration(seconds: 30),    // Timeout de envío
      followRedirects: true,
      maxRedirects: 3,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Interceptor para manejo de conectividad
    _dio.interceptors.add(ConnectivityInterceptor(_connectivityService));
    
    // Interceptor para logging en debug
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (object) => debugPrint(object.toString()),
      ));
    }

    // Interceptor para manejo de errores
    _dio.interceptors.add(ErrorInterceptor());
  }

  /// Realiza una petición GET con manejo de conectividad
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _connectivityService.retryWithBackoff(() async {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  /// Realiza una petición POST con manejo de conectividad
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _connectivityService.retryWithBackoff(() async {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  /// Realiza una petición PUT con manejo de conectividad
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _connectivityService.retryWithBackoff(() async {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    });
  }

  /// Realiza una petición DELETE con manejo de conectividad
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _connectivityService.retryWithBackoff(() async {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    });
  }
}

/// Interceptor para verificar conectividad antes de realizar peticiones
class ConnectivityInterceptor extends Interceptor {
  final ConnectivityService _connectivityService;

  ConnectivityInterceptor(this._connectivityService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Verificar conectividad antes de realizar la petición
    if (!_connectivityService.isConnected) {
      try {
        await _connectivityService.waitForConnection(
          timeout: const Duration(seconds: 10),
        );
      } catch (e) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: NetworkException.noConnection(),
            type: DioExceptionType.connectionError,
          ),
        );
        return;
      }
    }

    handler.next(options);
  }
}

/// Interceptor para manejo centralizado de errores
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        appException = NetworkException.timeout();
        break;
      
      case DioExceptionType.connectionError:
        if (err.error is SocketException) {
          appException = NetworkException.noConnection();
        } else {
          appException = NetworkException.serverError();
        }
        break;
      
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        switch (statusCode) {
          case 400:
            appException = NetworkException.badRequest();
            break;
          case 401:
            appException = NetworkException.unauthorized();
            break;
          case 403:
            appException = NetworkException.forbidden();
            break;
          case 404:
            appException = NetworkException.notFound();
            break;
          case 500:
          case 502:
          case 503:
          case 504:
            appException = NetworkException.serverError();
            break;
          default:
            appException = NetworkException(
              'Error HTTP $statusCode',
              code: 'http-$statusCode',
            );
        }
        break;
      
      case DioExceptionType.cancel:
        // No convertir errores de cancelación
        handler.next(err);
        return;
      
      case DioExceptionType.badCertificate:
        appException = const NetworkException(
          'Certificado SSL inválido',
          code: 'ssl-error',
        );
        break;
      
      case DioExceptionType.unknown:
      default:
        if (err.error is SocketException) {
          appException = NetworkException.noConnection();
        } else {
          appException = NetworkException(
            err.message ?? 'Error de red desconocido',
            code: 'unknown-network-error',
            originalError: err.error,
          );
        }
    }

    debugPrint('HTTP Error: ${appException.message}');
    
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: appException,
        type: err.type,
        response: err.response,
      ),
    );
  }
}

/// Extensión para facilitar el uso del HttpService
extension HttpServiceExtension on HttpService {
  /// Descarga un archivo con progreso
  Future<void> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    await _connectivityService.retryWithBackoff(() async {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    });
  }

  /// Sube un archivo con progreso
  Future<Response> uploadFile(
    String url,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    final formData = FormData.fromMap({
      ...?data,
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    return await post(
      url,
      data: formData,
      onSendProgress: onSendProgress,
      cancelToken: cancelToken,
    );
  }
}