// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Salas & Beats';

  @override
  String get appDescription =>
      'Marketplace para alugar salas de ensaio e estúdios de gravação';

  @override
  String get welcome => 'Bem-vindo';

  @override
  String get welcomeMessage => 'Encontre o espaço perfeito para sua música';

  @override
  String get getStarted => 'Começar';

  @override
  String get login => 'Entrar';

  @override
  String get register => 'Registrar';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get confirmPassword => 'Confirmar Senha';

  @override
  String get forgotPassword => 'Esqueceu sua senha?';

  @override
  String get resetPassword => 'Redefinir Senha';

  @override
  String get signInWithGoogle => 'Entrar com Google';

  @override
  String get signInWithApple => 'Entrar com Apple';

  @override
  String get home => 'Início';

  @override
  String get search => 'Buscar';

  @override
  String get bookings => 'Reservas';

  @override
  String get profile => 'Perfil';

  @override
  String get searchStudios => 'Buscar estúdios...';

  @override
  String get nearbyStudios => 'Estúdios Próximos';

  @override
  String get popularStudios => 'Estúdios Populares';

  @override
  String get recentlyViewed => 'Visualizados Recentemente';

  @override
  String get filters => 'Filtros';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get price => 'Preço';

  @override
  String get rating => 'Avaliação';

  @override
  String get distance => 'Distância';

  @override
  String get availability => 'Disponibilidade';

  @override
  String get studioType => 'Tipo de Estúdio';

  @override
  String get rehearsalRoom => 'Sala de Ensaio';

  @override
  String get recordingStudio => 'Estúdio de Gravação';

  @override
  String get liveRoom => 'Sala Ao Vivo';

  @override
  String pricePerHour(int price) {
    return '\$$price/hora';
  }

  @override
  String priceRange(String min, String max) {
    return '$min - $max';
  }

  @override
  String get viewDetails => 'Ver Detalhes';

  @override
  String get bookNow => 'Reservar Agora';

  @override
  String get selectDate => 'Selecionar Data';

  @override
  String get selectTime => 'Selecionar Horário';

  @override
  String get duration => 'Duração';

  @override
  String get hours => 'horas';

  @override
  String get minutes => 'minutos';

  @override
  String get totalPrice => 'Preço Total';

  @override
  String get confirmBooking => 'Confirmar Reserva';

  @override
  String get paymentMethod => 'Método de Pagamento';

  @override
  String get creditCard => 'Cartão de Crédito';

  @override
  String get paypal => 'PayPal';

  @override
  String get applePay => 'Apple Pay';

  @override
  String get googlePay => 'Google Pay';

  @override
  String get payNow => 'Pagar Agora';

  @override
  String get bookingConfirmed => 'Reserva Confirmada';

  @override
  String get bookingDetails => 'Detalhes da Reserva';

  @override
  String get bookingId => 'ID da Reserva';

  @override
  String get studioName => 'Nome do Estúdio';

  @override
  String get date => 'Data';

  @override
  String get time => 'Horário';

  @override
  String get location => 'Localização';

  @override
  String get contact => 'Contato';

  @override
  String get directions => 'Direções';

  @override
  String get callStudio => 'Ligar para o Estúdio';

  @override
  String get messageStudio => 'Enviar Mensagem';

  @override
  String get cancelBooking => 'Cancelar Reserva';

  @override
  String get modifyBooking => 'Modificar Reserva';

  @override
  String get upcomingBookings => 'Próximas Reservas';

  @override
  String get pastBookings => 'Reservas Anteriores';

  @override
  String get noBookings => 'Você não tem reservas';

  @override
  String get exploreStudios => 'Explorar Estúdios';

  @override
  String get rateExperience => 'Avaliar Experiência';

  @override
  String get writeReview => 'Escrever Avaliação';

  @override
  String get submitReview => 'Enviar Avaliação';

  @override
  String get reviews => 'Avaliações';

  @override
  String get photos => 'Fotos';

  @override
  String get amenities => 'Comodidades';

  @override
  String get equipment => 'Equipamentos';

  @override
  String get rules => 'Regras';

  @override
  String get cancellationPolicy => 'Política de Cancelamento';

  @override
  String get settings => 'Configurações';

  @override
  String get notifications => 'Notificações';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get languageUpdated => 'Idioma atualizado';

  @override
  String get welcomeBack => 'Bem-vindo de volta';

  @override
  String get signInToContinue => 'Faça login para continuar';

  @override
  String get emailHint => 'seu@email.com';

  @override
  String get passwordHint => 'Sua senha';

  @override
  String get enterEmail => 'Digite seu e-mail';

  @override
  String get enterValidEmail => 'Digite um e-mail válido';

  @override
  String get enterPassword => 'Digite sua senha';

  @override
  String passwordMinLength(int minLength) {
    return 'A senha deve ter pelo menos $minLength caracteres';
  }

  @override
  String get completeAllFields => 'Complete todos os campos corretamente';

  @override
  String get signIn => 'Entrar';

  @override
  String get completeForm => 'Complete o formulário';

  @override
  String get or => 'OU';

  @override
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get continueWithApple => 'Continuar com Apple';

  @override
  String get createUserDocument => 'Criar Documento do Usuário (Temporário)';

  @override
  String get noAccount => 'Não tem uma conta?';

  @override
  String get signInError => 'Erro ao fazer login';

  @override
  String get unexpectedError => 'Erro inesperado. Tente novamente.';

  @override
  String get googleSignInError => 'Erro ao fazer login com Google';

  @override
  String get appleSignInError => 'Erro ao fazer login com Apple';

  @override
  String get userDocumentCreated => 'Documento do usuário criado com sucesso';

  @override
  String createDocumentError(String error) {
    return 'Erro ao criar documento: $error';
  }

  @override
  String get createAccount => 'Criar conta';

  @override
  String get joinMusicalCommunity => 'Junte-se à comunidade musical';

  @override
  String get accountType => 'Tipo de conta';

  @override
  String get musician => 'Músico';

  @override
  String get searchAndBookRooms => 'Busque e reserve salas';

  @override
  String get host => 'Anfitrião';

  @override
  String get rentYourSpace => 'Alugue seu espaço';

  @override
  String get fullName => 'Nome completo';

  @override
  String get yourName => 'Seu nome';

  @override
  String get enterName => 'Digite seu nome';

  @override
  String get nameMinLength => 'O nome deve ter pelo menos 2 caracteres';

  @override
  String get emailAddress => 'Endereço de email';

  @override
  String get phoneOptional => 'Telefone (opcional)';

  @override
  String get phoneHint => '+55 11 99999-9999';

  @override
  String get enterValidPhone => 'Digite um número de telefone válido';

  @override
  String passwordMinLengthHint(int length) {
    return 'Mínimo $length caracteres';
  }

  @override
  String passwordHelperText(int length) {
    return 'Deve ter pelo menos $length caracteres';
  }

  @override
  String passwordMinLengthError(int length) {
    return 'A senha deve ter pelo menos $length caracteres';
  }

  @override
  String get repeatPassword => 'Repita sua senha';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get confirmYourPassword => 'Confirme sua senha';

  @override
  String get acceptTerms => 'Aceito os ';

  @override
  String get termsAndConditions => 'termos e condições';

  @override
  String get andPrivacyPolicy => ' e política de privacidade';

  @override
  String get completeFollowingFields => 'Complete os seguintes campos:';

  @override
  String get validName => 'Nome válido';

  @override
  String get validEmail => 'Email válido';

  @override
  String get securePassword => 'Senha segura';

  @override
  String get passwordsMatch => 'Senhas coincidem';

  @override
  String get termsAccepted => 'Termos aceitos';

  @override
  String get createAccountButton => 'Criar Conta';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta? ';

  @override
  String get mustAcceptTerms => 'Você deve aceitar os termos e condições';

  @override
  String get accountCreatedSuccessfully =>
      'Conta criada com sucesso. Verifique seu email.';

  @override
  String get unknownRegistrationError => 'Erro desconhecido durante o registro';

  @override
  String get googleRegistrationError => 'Erro ao registrar com Google';

  @override
  String get termsAndConditionsTitle => 'Termos e Condições';

  @override
  String get termsContent =>
      'Ao usar o Salas & Beats, você aceita nossos termos de serviço e política de privacidade.\n\nComo músico, você pode buscar e reservar salas de ensaio.\n\nComo anfitrião, você pode listar seu espaço e receber pagamentos por reservas.\n\nNos reservamos o direito de suspender contas que violem nossas políticas.';

  @override
  String get close => 'Fechar';

  @override
  String get theme => 'Tema';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get darkTheme => 'Tema Escuro';

  @override
  String get systemTheme => 'Tema do Sistema';

  @override
  String get privacy => 'Privacidade';

  @override
  String get termsOfService => 'Termos de Serviço';

  @override
  String get privacyPolicy => 'Política de Privacidade';

  @override
  String get help => 'Ajuda';

  @override
  String get support => 'Suporte';

  @override
  String get faq => 'Perguntas Frequentes';

  @override
  String get contactUs => 'Entre em Contato';

  @override
  String get logout => 'Sair';

  @override
  String get deleteAccount => 'Excluir Conta';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get firstName => 'Nome';

  @override
  String get lastName => 'Sobrenome';

  @override
  String get phoneNumber => 'Número de Telefone';

  @override
  String get dateOfBirth => 'Data de Nascimento';

  @override
  String get saveChanges => 'Salvar Alterações';

  @override
  String get discardChanges => 'Descartar Alterações';

  @override
  String get loading => 'Carregando...';

  @override
  String get error => 'Erro';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get share => 'Compartilhar';

  @override
  String get favorite => 'Favorito';

  @override
  String get unfavorite => 'Remover dos Favoritos';

  @override
  String get favorites => 'Favoritos';

  @override
  String get noFavorites => 'Você não tem favoritos';

  @override
  String get addToFavorites => 'Adicionar aos Favoritos';

  @override
  String get removeFromFavorites => 'Remover dos Favoritos';

  @override
  String get searchResults => 'Resultados da Busca';

  @override
  String get noResults => 'Nenhum resultado encontrado';

  @override
  String get tryDifferentSearch => 'Tente uma busca diferente';

  @override
  String get clearFilters => 'Limpar filtros';

  @override
  String get applyFilters => 'Aplicar filtros';

  @override
  String get map => 'Mapa';

  @override
  String get list => 'Lista';

  @override
  String get openingHours => 'Horários de Funcionamento';

  @override
  String get closed => 'Fechado';

  @override
  String get open => 'Aberto';

  @override
  String opensAt(String time) {
    return 'Abre às $time';
  }

  @override
  String closesAt(String time) {
    return 'Fecha às $time';
  }

  @override
  String get available => 'Disponível';

  @override
  String get unavailable => 'Indisponível';

  @override
  String get booked => 'Reservado';

  @override
  String get pending => 'Pendente';

  @override
  String get confirmed => 'Confirmado';

  @override
  String get cancelled => 'Cancelado';

  @override
  String get completed => 'Concluído';

  @override
  String get refunded => 'Reembolsado';

  @override
  String hello(String name) {
    return 'Olá, $name';
  }

  @override
  String get findPerfectSpace => 'Encontre seu espaço musical perfeito';

  @override
  String get searchPlaceholder => 'Buscar salas, localização...';

  @override
  String upToCapacity(int capacity) {
    return 'Até $capacity pessoas';
  }

  @override
  String get noRoomsFound => 'Nenhuma sala encontrada';

  @override
  String get adjustFiltersMessage =>
      'Tente ajustar seus filtros ou buscar em outra localização';

  @override
  String get clear => 'Limpar';

  @override
  String get city => 'Cidade';

  @override
  String get all => 'Todas';

  @override
  String maxPricePerHour(int price) {
    return 'Preço máximo por hora: \$$price';
  }

  @override
  String get explore => 'Explorar';

  @override
  String get messages => 'Mensagens';

  @override
  String get profileCreationError => 'Error al crear perfil';

  @override
  String get profileCreationNetworkError =>
      'No se pudo crear el perfil. Verifica tu conexión a internet e intenta nuevamente.';

  @override
  String get profileCreationValidationError =>
      'Los datos del perfil no son válidos. Revisa la información ingresada.';

  @override
  String get profileCreationPermissionError =>
      'No tienes permisos para crear este perfil. Contacta al administrador.';

  @override
  String get profileCreationServerError =>
      'Error interno del servidor. Intenta nuevamente en unos minutos.';

  @override
  String get profileCreationTimeoutError =>
      'La creación del perfil tardó demasiado tiempo. Verifica tu conexión e intenta nuevamente.';

  @override
  String get profileUpdateError => 'Error al actualizar perfil';

  @override
  String get profileUpdateNetworkError =>
      'No se pudo actualizar el perfil. Verifica tu conexión a internet.';

  @override
  String get profileUpdateValidationError =>
      'Los datos ingresados no son válidos. Revisa la información.';

  @override
  String get profileUpdatePermissionError =>
      'No tienes permisos para actualizar este perfil.';

  @override
  String get profileIncompleteError =>
      'Tu perfil está incompleto. Completa todos los campos requeridos.';

  @override
  String get profileNameRequiredError =>
      'El nombre es obligatorio para crear tu perfil.';

  @override
  String get profileEmailRequiredError =>
      'El email es obligatorio para crear tu perfil.';

  @override
  String get profileRoleRequiredError =>
      'Debes seleccionar un tipo de cuenta (Músico o Anfitrión).';

  @override
  String get profileNameTooShortError =>
      'El nombre debe tener al menos 2 caracteres.';

  @override
  String get profileNameTooLongError =>
      'El nombre no puede tener más de 50 caracteres.';

  @override
  String get profileEmailInvalidError => 'El formato del email no es válido.';

  @override
  String get profilePhoneInvalidError =>
      'El formato del teléfono no es válido.';

  @override
  String get profileBioTooLongError =>
      'La biografía no puede tener más de 500 caracteres.';

  @override
  String get profileCreationSuccessMessage =>
      '¡Perfil creado exitosamente! Bienvenido a Salas & Beats.';

  @override
  String get profileUpdateSuccessMessage => 'Perfil actualizado exitosamente.';
}
