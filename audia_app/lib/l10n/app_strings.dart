import 'dart:io' show Platform;

class AppStrings {
  static const Map<String, String> _localeNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'pt': 'Português',
    'de': 'Deutsch',
    'it': 'Italiano',
    'ru': 'Русский',
    'ar': 'العربية',
    'zh': '中文',
    'ko': '한국어',
    'ja': '日本語',
  };

  static const List<String> supportedLocales = [
    'en', 'es', 'fr', 'pt', 'de', 'it', 'ru', 'ar', 'zh', 'ko', 'ja',
  ];

  static String defaultLocale = 'en';

  static String localeName(String code) => _localeNames[code] ?? code;

  static String? _detectDeviceLocale() {
    try {
      final locale = Platform.localeName.split('_').first.toLowerCase();
      if (supportedLocales.contains(locale)) return locale;
    } catch (_) {}
    return null;
  }

  static String get initialLocale => _detectDeviceLocale() ?? defaultLocale;

  static String _locale = defaultLocale;

  static String get locale => _locale;
  static void setLocale(String code) {
    if (supportedLocales.contains(code)) _locale = code;
  }

  static String _t(Map<String, String> map) => map[_locale] ?? map[defaultLocale] ?? '';

  static String get appName => _t({
    'en': 'Audia',
    'es': 'Audia',
    'fr': 'Audia',
    'pt': 'Audia',
    'de': 'Audia',
    'it': 'Audia',
    'ru': 'Audia',
    'ar': 'Audia',
    'zh': 'Audia',
    'ko': 'Audia',
    'ja': 'Audia',
  });

  static String get home => _t({
    'en': 'Home',
    'es': 'Inicio',
    'fr': 'Accueil',
    'pt': 'Início',
    'de': 'Start',
    'it': 'Home',
    'ru': 'Главная',
    'ar': 'الرئيسية',
    'zh': '首页',
    'ko': '홈',
    'ja': 'ホーム',
  });

  static String get inbox => _t({
    'en': 'Inbox',
    'es': 'Bandeja',
    'fr': 'Boîte',
    'pt': 'Caixa',
    'de': 'Posteingang',
    'it': 'Posta',
    'ru': 'Входящие',
    'ar': 'الوارد',
    'zh': '收件箱',
    'ko': '받은함',
    'ja': '受信トレイ',
  });

  static String get inboxFull => _t({
    'en': 'Inbox',
    'es': 'Bandeja de entrada',
    'fr': 'Boîte de réception',
    'pt': 'Caixa de entrada',
    'de': 'Posteingang',
    'it': 'Posta in arrivo',
    'ru': 'Входящие',
    'ar': 'صندوق الوارد',
    'zh': '收件箱',
    'ko': '받은 편지함',
    'ja': '受信トレイ',
  });

  static String get friends => _t({
    'en': 'Friends',
    'es': 'Amigos',
    'fr': 'Amis',
    'pt': 'Amigos',
    'de': 'Freunde',
    'it': 'Amici',
    'ru': 'Друзья',
    'ar': 'الأصدقاء',
    'zh': '朋友',
    'ko': '친구',
    'ja': '友達',
  });

  static String get profile => _t({
    'en': 'Profile',
    'es': 'Perfil',
    'fr': 'Profil',
    'pt': 'Perfil',
    'de': 'Profil',
    'it': 'Profilo',
    'ru': 'Профиль',
    'ar': 'الملف',
    'zh': '个人资料',
    'ko': '프로필',
    'ja': 'プロフィール',
  });

  static String get forYou => _t({
    'en': 'For you',
    'es': 'Para ti',
    'fr': 'Pour toi',
    'pt': 'Para você',
    'de': 'Für dich',
    'it': 'Per te',
    'ru': 'Для вас',
    'ar': 'لك',
    'zh': '为你推荐',
    'ko': '추천',
    'ja': 'あなたへ',
  });

  static String get contacts => _t({
    'en': 'Contacts',
    'es': 'Contactos',
    'fr': 'Contacts',
    'pt': 'Contactos',
    'de': 'Kontakte',
    'it': 'Contatti',
    'ru': 'Контакты',
    'ar': 'جهات الاتصال',
    'zh': '联系人',
    'ko': '연락처',
    'ja': '連絡先',
  });

  static String get following => _t({
    'en': 'Following',
    'es': 'Siguiendo',
    'fr': 'Abonnements',
    'pt': 'Seguindo',
    'de': 'Folge ich',
    'it': 'Seguiti',
    'ru': 'Подписки',
    'ar': 'المتابَعون',
    'zh': '关注',
    'ko': '팔로잉',
    'ja': 'フォロー中',
  });

  static String get settings => _t({
    'en': 'Settings',
    'es': 'Ajustes',
    'fr': 'Paramètres',
    'pt': 'Configurações',
    'de': 'Einstellungen',
    'it': 'Impostazioni',
    'ru': 'Настройки',
    'ar': 'الإعدادات',
    'zh': '设置',
    'ko': '설정',
    'ja': '設定',
  });

  static String get editProfile => _t({
    'en': 'Edit profile',
    'es': 'Editar perfil',
    'fr': 'Modifier le profil',
    'pt': 'Editar perfil',
    'de': 'Profil bearbeiten',
    'it': 'Modifica profilo',
    'ru': 'Редактировать профиль',
    'ar': 'تعديل الملف',
    'zh': '编辑资料',
    'ko': '프로필 편집',
    'ja': 'プロフィール編集',
  });

  static String get noBio => _t({
    'en': 'No bio',
    'es': 'Sin biografía',
    'fr': 'Pas de biographie',
    'pt': 'Sem biografia',
    'de': 'Keine Biografie',
    'it': 'Nessuna biografia',
    'ru': 'Нет описания',
    'ar': 'لا توجد سيرة',
    'zh': '暂无简介',
    'ko': '자기소개 없음',
    'ja': '自己紹介なし',
  });

  static String get myAudios => _t({
    'en': 'My audios',
    'es': 'Mis audios',
    'fr': 'Mes audios',
    'pt': 'Meus áudios',
    'de': 'Meine Audios',
    'it': 'I miei audio',
    'ru': 'Мои аудио',
    'ar': 'مقاطعي الصوتية',
    'zh': '我的音频',
    'ko': '내 오디오',
    'ja': 'マイオーディオ',
  });

  static String get noAudiosYet => _t({
    'en': 'No audios yet',
    'es': 'No has subido audios aún',
    'fr': 'Pas encore d\'audios',
    'pt': 'Nenhum áudio ainda',
    'de': 'Noch keine Audios',
    'it': 'Ancora nessun audio',
    'ru': 'Пока нет аудио',
    'ar': 'لا توجد مقاطع صوتية بعد',
    'zh': '还没有音频',
    'ko': '아직 오디오가 없습니다',
    'ja': 'まだオーディオがありません',
  });

  static String get followers => _t({
    'en': 'Followers',
    'es': 'Seguidores',
    'fr': 'Abonnés',
    'pt': 'Seguidores',
    'de': 'Follower',
    'it': 'Followers',
    'ru': 'Подписчики',
    'ar': 'المتابعون',
    'zh': '粉丝',
    'ko': '팔로워',
    'ja': 'フォロワー',
  });

  static String get likes => _t({
    'en': 'Likes',
    'es': 'Likes',
    'fr': 'J\'aime',
    'pt': 'Curtidas',
    'de': 'Gefällt mir',
    'it': 'Mi piace',
    'ru': 'Лайки',
    'ar': 'الإعجابات',
    'zh': '赞',
    'ko': '좋아요',
    'ja': 'いいね',
  });

  static String get noUsers => _t({
    'en': 'No users',
    'es': 'No hay usuarios',
    'fr': 'Aucun utilisateur',
    'pt': 'Nenhum usuário',
    'de': 'Keine Benutzer',
    'it': 'Nessun utente',
    'ru': 'Нет пользователей',
    'ar': 'لا يوجد مستخدمين',
    'zh': '没有用户',
    'ko': '사용자가 없습니다',
    'ja': 'ユーザーがいません',
  });

  static String get comments => _t({
    'en': 'Comments',
    'es': 'Comentarios',
    'fr': 'Commentaires',
    'pt': 'Comentários',
    'de': 'Kommentare',
    'it': 'Commenti',
    'ru': 'Комментарии',
    'ar': 'التعليقات',
    'zh': '评论',
    'ko': '댓글',
    'ja': 'コメント',
  });

  static String get noComments => _t({
    'en': 'No comments',
    'es': 'Sin comentarios',
    'fr': 'Aucun commentaire',
    'pt': 'Sem comentários',
    'de': 'Keine Kommentare',
    'it': 'Nessun commento',
    'ru': 'Нет комментариев',
    'ar': 'لا توجد تعليقات',
    'zh': '没有评论',
    'ko': '댓글이 없습니다',
    'ja': 'コメントがありません',
  });

  static String get writeComment => _t({
    'en': 'Write a comment...',
    'es': 'Escribe un comentario...',
    'fr': 'Écrire un commentaire...',
    'pt': 'Escreva um comentário...',
    'de': 'Schreibe einen Kommentar...',
    'it': 'Scrivi un commento...',
    'ru': 'Напишите комментарий...',
    'ar': 'اكتب تعليقاً...',
    'zh': '写评论...',
    'ko': '댓글 쓰기...',
    'ja': 'コメントを書く...',
  });

  static String get publishAudio => _t({
    'en': 'Publish audio',
    'es': 'Publicar audio',
    'fr': 'Publier l\'audio',
    'pt': 'Publicar áudio',
    'de': 'Audio veröffentlichen',
    'it': 'Pubblica audio',
    'ru': 'Опубликовать аудио',
    'ar': 'نشر مقطع صوتي',
    'zh': '发布音频',
    'ko': '오디오 게시',
    'ja': 'オーディオを公開',
  });

  static String get publishing => _t({
    'en': 'Publishing...',
    'es': 'Publicando...',
    'fr': 'Publication...',
    'pt': 'Publicando...',
    'de': 'Veröffentlichen...',
    'it': 'Pubblicazione...',
    'ru': 'Публикация...',
    'ar': 'جاري النشر...',
    'zh': '发布中...',
    'ko': '게시 중...',
    'ja': '公開中...',
  });

  static String get audioPublished => _t({
    'en': 'Audio published successfully',
    'es': 'Audio publicado con éxito',
    'fr': 'Audio publié avec succès',
    'pt': 'Áudio publicado com sucesso',
    'de': 'Audio erfolgreich veröffentlicht',
    'it': 'Audio pubblicato con successo',
    'ru': 'Аудио успешно опубликовано',
    'ar': 'تم نشر المقطع الصوتي بنجاح',
    'zh': '音频发布成功',
    'ko': '오디오가 성공적으로 게시되었습니다',
    'ja': 'オーディオを公開しました',
  });

  static String get audioBackground => _t({
    'en': 'Audio background',
    'es': 'Fondo del audio',
    'fr': 'Fond de l\'audio',
    'pt': 'Fundo do áudio',
    'de': 'Audio-Hintergrund',
    'it': 'Sfondo audio',
    'ru': 'Фон аудио',
    'ar': 'خلفية المقطع الصوتي',
    'zh': '音频背景',
    'ko': '오디오 배경',
    'ja': 'オーディオ背景',
  });

  static String get chooseImage => _t({
    'en': 'Choose image from gallery',
    'es': 'Elegir imagen de galería',
    'fr': 'Choisir une image',
    'pt': 'Escolher imagem da galeria',
    'de': 'Bild aus Galerie wählen',
    'it': 'Scegli immagine dalla galleria',
    'ru': 'Выбрать изображение из галереи',
    'ar': 'اختر صورة من المعرض',
    'zh': '从相册选择图片',
    'ko': '갤러리에서 이미지 선택',
    'ja': 'ギャラリーから画像を選択',
  });

  static String get changeImage => _t({
    'en': 'Change image',
    'es': 'Cambiar imagen',
    'fr': 'Changer d\'image',
    'pt': 'Alterar imagem',
    'de': 'Bild ändern',
    'it': 'Cambia immagine',
    'ru': 'Изменить изображение',
    'ar': 'تغيير الصورة',
    'zh': '更改图片',
    'ko': '이미지 변경',
    'ja': '画像を変更',
  });

  static String get thisIsHowItLooks => _t({
    'en': 'This is how your audio will look',
    'es': 'Así se verá tu audio',
    'fr': 'Voici à quoi ressemblera votre audio',
    'pt': 'Assim será seu áudio',
    'de': 'So wird dein Audio aussehen',
    'it': 'Ecco come apparirà il tuo audio',
    'ru': 'Так будет выглядеть ваше аудио',
    'ar': 'هكذا سيبدو المقطع الصوتي',
    'zh': '这是你的音频的外观',
    'ko': '오디오가 이렇게 표시됩니다',
    'ja': 'オーディオはこのように表示されます',
  });

  static String get yourUser => _t({
    'en': 'Your user',
    'es': 'Tu usuario',
    'fr': 'Votre utilisateur',
    'pt': 'Seu usuário',
    'de': 'Dein Benutzer',
    'it': 'Il tuo utente',
    'ru': 'Ваш пользователь',
    'ar': 'مستخدمك',
    'zh': '你的用户名',
    'ko': '사용자',
    'ja': 'あなたのユーザー',
  });

  static String get saveChanges => _t({
    'en': 'Save changes',
    'es': 'Guardar cambios',
    'fr': 'Enregistrer',
    'pt': 'Salvar alterações',
    'de': 'Änderungen speichern',
    'it': 'Salva modifiche',
    'ru': 'Сохранить изменения',
    'ar': 'حفظ التغييرات',
    'zh': '保存更改',
    'ko': '변경사항 저장',
    'ja': '変更を保存',
  });

  static String get username => _t({
    'en': 'Username',
    'es': 'Nombre de usuario',
    'fr': 'Nom d\'utilisateur',
    'pt': 'Nome de usuário',
    'de': 'Benutzername',
    'it': 'Nome utente',
    'ru': 'Имя пользователя',
    'ar': 'اسم المستخدم',
    'zh': '用户名',
    'ko': '사용자 이름',
    'ja': 'ユーザー名',
  });

  static String get bio => _t({
    'en': 'Biography',
    'es': 'Biografía',
    'fr': 'Biographie',
    'pt': 'Biografia',
    'de': 'Biografie',
    'it': 'Biografia',
    'ru': 'Биография',
    'ar': 'السيرة الذاتية',
    'zh': '个人简介',
    'ko': '자기소개',
    'ja': '自己紹介',
  });

  static String get language => _t({
    'en': 'Language',
    'es': 'Idioma',
    'fr': 'Langue',
    'pt': 'Idioma',
    'de': 'Sprache',
    'it': 'Lingua',
    'ru': 'Язык',
    'ar': 'اللغة',
    'zh': '语言',
    'ko': '언어',
    'ja': '言語',
  });

  static String get chooseLanguage => _t({
    'en': 'Choose language',
    'es': 'Elige un idioma',
    'fr': 'Choisissez une langue',
    'pt': 'Escolha um idioma',
    'de': 'Sprache wählen',
    'it': 'Scegli una lingua',
    'ru': 'Выберите язык',
    'ar': 'اختر لغة',
    'zh': '选择语言',
    'ko': '언어 선택',
    'ja': '言語を選択',
  });

  static String get privateAccount => _t({
    'en': 'Private account',
    'es': 'Cuenta privada',
    'fr': 'Compte privé',
    'pt': 'Conta privada',
    'de': 'Privates Konto',
    'it': 'Account privato',
    'ru': 'Закрытый аккаунт',
    'ar': 'حساب خاص',
    'zh': '私密账户',
    'ko': '비공개 계정',
    'ja': '非公開アカウント',
  });

  static String get privateAccountDesc => _t({
    'en': 'Only friends can hear your audios',
    'es': 'Solo tus amigos podrán escuchar tus audios',
    'fr': 'Seuls vos amis peuvent écouter vos audios',
    'pt': 'Apenas amigos podem ouvir seus áudios',
    'de': 'Nur Freunde können deine Audios hören',
    'it': 'Solo gli amici possono ascoltare i tuoi audio',
    'ru': 'Только друзья могут слушать ваши аудио',
    'ar': 'الأصدقاء فقط يمكنهم الاستماع إلى مقاطعك',
    'zh': '只有朋友可以听你的音频',
    'ko': '친구만 내 오디오를 들을 수 있습니다',
    'ja': '友達だけがあなたのオーディオを聴けます',
  });

  static String get blockedAccounts => _t({
    'en': 'Blocked accounts',
    'es': 'Cuentas bloqueadas',
    'fr': 'Comptes bloqués',
    'pt': 'Contas bloqueadas',
    'de': 'Blockierte Konten',
    'it': 'Account bloccati',
    'ru': 'Заблокированные аккаунты',
    'ar': 'الحسابات المحظورة',
    'zh': '已屏蔽的账户',
    'ko': '차단된 계정',
    'ja': 'ブロックしたアカウント',
  });

  static String get noBlocked => _t({
    'en': 'No blocked accounts',
    'es': 'No hay cuentas bloqueadas',
    'fr': 'Aucun compte bloqué',
    'pt': 'Nenhuma conta bloqueada',
    'de': 'Keine blockierten Konten',
    'it': 'Nessun account bloccato',
    'ru': 'Нет заблокированных аккаунтов',
    'ar': 'لا توجد حسابات محظورة',
    'zh': '没有已屏蔽的账户',
    'ko': '차단된 계정이 없습니다',
    'ja': 'ブロックしたアカウントはありません',
  });

  static String get unblock => _t({
    'en': 'Unblock',
    'es': 'Desbloquear',
    'fr': 'Débloquer',
    'pt': 'Desbloquear',
    'de': 'Entsperren',
    'it': 'Sblocca',
    'ru': 'Разблокировать',
    'ar': 'إلغاء الحظر',
    'zh': '解除屏蔽',
    'ko': '차단 해제',
    'ja': 'ブロック解除',
  });

  static String get communityGuidelines => _t({
    'en': 'Community Guidelines',
    'es': 'Normas de la comunidad',
    'fr': 'Règles de la communauté',
    'pt': 'Regras da comunidade',
    'de': 'Community-Richtlinien',
    'it': 'Regole della community',
    'ru': 'Правила сообщества',
    'ar': 'إرشادات المجتمع',
    'zh': '社区准则',
    'ko': '커뮤니티 가이드라인',
    'ja': 'コミュニティガイドライン',
  });

  static String get announcements => _t({
    'en': 'Announcements',
    'es': 'Anuncios',
    'fr': 'Annonces',
    'pt': 'Anúncios',
    'de': 'Ankündigungen',
    'it': 'Annunci',
    'ru': 'Объявления',
    'ar': 'الإعلانات',
    'zh': '公告',
    'ko': '공지사항',
    'ja': 'お知らせ',
  });

  static String get appearance => _t({
    'en': 'Appearance',
    'es': 'Apariencia',
    'fr': 'Apparence',
    'pt': 'Aparência',
    'de': 'Erscheinungsbild',
    'it': 'Aspetto',
    'ru': 'Внешний вид',
    'ar': 'المظهر',
    'zh': '外观',
    'ko': '외관',
    'ja': '外観',
  });

  static String get darkMode => _t({
    'en': 'Dark mode',
    'es': 'Modo oscuro',
    'fr': 'Mode sombre',
    'pt': 'Modo escuro',
    'de': 'Dunkelmodus',
    'it': 'Modalità scura',
    'ru': 'Тёмная тема',
    'ar': 'الوضع الداكن',
    'zh': '深色模式',
    'ko': '다크 모드',
    'ja': 'ダークモード',
  });

  static String get lightMode => _t({
    'en': 'Light mode',
    'es': 'Modo claro',
    'fr': 'Mode clair',
    'pt': 'Modo claro',
    'de': 'Hellmodus',
    'it': 'Modalità chiara',
    'ru': 'Светлая тема',
    'ar': 'الوضع الفاتح',
    'zh': '浅色模式',
    'ko': '라이트 모드',
    'ja': 'ライトモード',
  });

  static String get logout => _t({
    'en': 'Log out',
    'es': 'Cerrar sesión',
    'fr': 'Se déconnecter',
    'pt': 'Sair',
    'de': 'Abmelden',
    'it': 'Esci',
    'ru': 'Выйти',
    'ar': 'تسجيل الخروج',
    'zh': '退出登录',
    'ko': '로그아웃',
    'ja': 'ログアウト',
  });

  static String get logoutConfirm => _t({
    'en': 'Are you sure you want to log out?',
    'es': '¿Estás seguro de que quieres cerrar sesión?',
    'fr': 'Êtes-vous sûr de vouloir vous déconnecter ?',
    'pt': 'Tem certeza que deseja sair?',
    'de': 'Bist du sicher, dass du dich abmelden möchtest?',
    'it': 'Sei sicuro di voler uscire?',
    'ru': 'Вы уверены, что хотите выйти?',
    'ar': 'هل أنت متأكد من تسجيل الخروج؟',
    'zh': '确定要退出登录吗？',
    'ko': '로그아웃 하시겠습니까?',
    'ja': 'ログアウトしてもよろしいですか？',
  });

  static String get cancel => _t({
    'en': 'Cancel',
    'es': 'Cancelar',
    'fr': 'Annuler',
    'pt': 'Cancelar',
    'de': 'Abbrechen',
    'it': 'Annulla',
    'ru': 'Отмена',
    'ar': 'إلغاء',
    'zh': '取消',
    'ko': '취소',
    'ja': 'キャンセル',
  });

  static String get confirm => _t({
    'en': 'Confirm',
    'es': 'Confirmar',
    'fr': 'Confirmer',
    'pt': 'Confirmar',
    'de': 'Bestätigen',
    'it': 'Conferma',
    'ru': 'Подтвердить',
    'ar': 'تأكيد',
    'zh': '确认',
    'ko': '확인',
    'ja': '確認',
  });

  static String get error => _t({
    'en': 'Error',
    'es': 'Error',
    'fr': 'Erreur',
    'pt': 'Erro',
    'de': 'Fehler',
    'it': 'Errore',
    'ru': 'Ошибка',
    'ar': 'خطأ',
    'zh': '错误',
    'ko': '오류',
    'ja': 'エラー',
  });

  static String get follow => _t({
    'en': 'Follow',
    'es': 'Seguir',
    'fr': 'Suivre',
    'pt': 'Seguir',
    'de': 'Folgen',
    'it': 'Segui',
    'ru': 'Подписаться',
    'ar': 'متابعة',
    'zh': '关注',
    'ko': '팔로우',
    'ja': 'フォロー',
  });

  static String get viewProfile => _t({
    'en': 'View profile',
    'es': 'Ver perfil',
    'fr': 'Voir le profil',
    'pt': 'Ver perfil',
    'de': 'Profil ansehen',
    'it': 'Vedi profilo',
    'ru': 'Посмотреть профиль',
    'ar': 'عرض الملف',
    'zh': '查看资料',
    'ko': '프로필 보기',
    'ja': 'プロフィールを見る',
  });

  static String get blockUser => _t({
    'en': 'Block user',
    'es': 'Bloquear usuario',
    'fr': 'Bloquer',
    'pt': 'Bloquear',
    'de': 'Blockieren',
    'it': 'Blocca',
    'ru': 'Заблокировать',
    'ar': 'حظر المستخدم',
    'zh': '屏蔽用户',
    'ko': '사용자 차단',
    'ja': 'ユーザーをブロック',
  });

  static String get blocked => _t({
    'en': 'Blocked',
    'es': 'Bloqueado',
    'fr': 'Bloqué',
    'pt': 'Bloqueado',
    'de': 'Blockiert',
    'it': 'Bloccato',
    'ru': 'Заблокирован',
    'ar': 'محظور',
    'zh': '已屏蔽',
    'ko': '차단됨',
    'ja': 'ブロック済み',
  });

  static String get audiaVersion => _t({
    'en': 'Audia v1.0.0',
    'es': 'Audia v1.0.0',
    'fr': 'Audia v1.0.0',
    'pt': 'Audia v1.0.0',
    'de': 'Audia v1.0.0',
    'it': 'Audia v1.0.0',
    'ru': 'Audia v1.0.0',
    'ar': 'Audia v1.0.0',
    'zh': 'Audia v1.0.0',
    'ko': 'Audia v1.0.0',
    'ja': 'Audia v1.0.0',
  });

  static String get normsTitle => _t({
    'en': 'Audia Community Guidelines',
    'es': 'Normas de la comunidad de Audia',
    'fr': 'Règles de la communauté Audia',
    'pt': 'Regras da comunidade Audia',
    'de': 'Audia Community-Richtlinien',
    'it': 'Regole della community Audia',
    'ru': 'Правила сообщества Audia',
    'ar': 'إرشادات مجتمع Audia',
    'zh': 'Audia 社区准则',
    'ko': 'Audia 커뮤니티 가이드라인',
    'ja': 'Audia コミュニティガイドライン',
  });

  static String get normsContent => _t({
    'en': '1. Respect all users\n2. No hate speech or harassment\n3. No explicit or offensive content\n4. No spam or misleading content\n5. Respect copyright and intellectual property\n6. No impersonation\n7. Report any violations\n8. Keep conversations civil',
    'es': '1. Respeta a todos los usuarios\n2. No toleramos discursos de odio o acoso\n3. No publiques contenido explícito u ofensivo\n4. No hagas spam o publiques contenido engañoso\n5. Respeta los derechos de autor y propiedad intelectual\n6. No te hagas pasar por otros\n7. Reporta cualquier infracción\n8. Mantén conversaciones respetuosas',
    'fr': '1. Respectez tous les utilisateurs\n2. Pas de discours haineux ou de harcèlement\n3. Pas de contenu explicite ou offensant\n4. Pas de spam ou de contenu trompeur\n5. Respectez le droit d\'auteur et la propriété intellectuelle\n6. Pas d\'usurpation d\'identité\n7. Signalez toute violation\n8. Gardez des conversations civilisées',
    'pt': '1. Respeite todos os usuários\n2. Discurso de ódio ou assédio não são tolerados\n3. Não publique conteúdo explícito ou ofensivo\n4. Sem spam ou conteúdo enganoso\n5. Respeite os direitos autorais e propriedade intelectual\n6. Não se passe por outros\n7. Denuncie qualquer violação\n8. Mantenha conversas respeitosas',
    'de': '1. Respektiere alle Benutzer\n2. Keine Hassrede oder Belästigung\n3. Keine expliziten oder anstößigen Inhalte\n4. Kein Spam oder irreführende Inhalte\n5. Urheberrechte und geistiges Eigentum respektieren\n6. Keine Identitätsdiebstahl\n7. Melde Verstöße\n8. Führe zivilisierte Gespräche',
    'it': '1. Rispetta tutti gli utenti\n2. Nessun discorso d\'odio o molestie\n3. Nessun contenuto esplicito o offensivo\n4. Nessuno spam o contenuti ingannevoli\n5. Rispetta il copyright e la proprietà intellettuale\n6. Nessuna impersonificazione\n7. Segnala qualsiasi violazione\n8. Mantieni conversazioni civili',
    'ru': '1. Уважайте всех пользователей\n2. Никаких оскорблений или преследований\n3. Никакого откровенного или оскорбительного контента\n4. Никакого спама или вводящего в заблуждение контента\n5. Уважайте авторские права и интеллектуальную собственность\n6. Не выдавайте себя за других\n7. Сообщайте о нарушениях\n8. Ведите себя цивилизованно',
    'ar': '1. احترم جميع المستخدمين\n2. لا للخطاب الكراهية أو التحرش\n3. لا للمحتوى الصريح أو المسيء\n4. لا للبريد العشوائي أو المحتوى المضلل\n5. احترم حقوق النشر والملكية الفكرية\n6. لا للانتحال\n7. أبلغ عن أي انتهاكات\n8. حافظ على المحادثات المهذبة',
    'zh': '1. 尊重所有用户\n2. 禁止仇恨言论或骚扰\n3. 禁止色情或攻击性内容\n4. 禁止垃圾信息或误导内容\n5. 尊重版权和知识产权\n6. 禁止冒充他人\n7. 举报任何违规行为\n8. 保持文明对话',
    'ko': '1. 모든 사용자를 존중하세요\n2. 혐오 발언이나 괴롭힘 금지\n3. 노골적이거나 공격적인 콘텐츠 금지\n4. 스팸 또는 오해의 소지가 있는 콘텐츠 금지\n5. 저작권 및 지적 재산권 존중\n6. 사칭 금지\n7. 위반 사항 신고\n8. 예의 바른 대화 유지',
    'ja': '1. すべてのユーザーを尊重してください\n2. ヘイトスピーチや嫌がらせ禁止\n3. 露骨または攻撃的なコンテンツ禁止\n4. スパムや誤解を招くコンテンツ禁止\n5. 著作権と知的財産権を尊重\n6. なりすまし禁止\n7. 違反を報告してください\n8. 礼儀正しい会話を心がけてください',
  });

  static String get noAnnouncements => _t({
    'en': 'No announcements yet',
    'es': 'No hay anuncios aún',
    'fr': 'Pas encore d\'annonces',
    'pt': 'Nenhum anúncio ainda',
    'de': 'Noch keine Ankündigungen',
    'it': 'Ancora nessun annuncio',
    'ru': 'Пока нет объявлений',
    'ar': 'لا توجد إعلانات بعد',
    'zh': '暂无公告',
    'ko': '아직 공지사항이 없습니다',
    'ja': 'まだお知らせはありません',
  });

  static String get blockConfirm => _t({
    'en': 'Are you sure you want to block this user?',
    'es': '¿Estás seguro de que quieres bloquear a este usuario?',
    'fr': 'Êtes-vous sûr de vouloir bloquer cet utilisateur ?',
    'pt': 'Tem certeza que deseja bloquear este usuário?',
    'de': 'Bist du sicher, dass du diesen Benutzer blockieren möchtest?',
    'it': 'Sei sicuro di voler bloccare questo utente?',
    'ru': 'Вы уверены, что хотите заблокировать этого пользователя?',
    'ar': 'هل أنت متأكد من حظر هذا المستخدم؟',
    'zh': '确定要屏蔽此用户吗？',
    'ko': '이 사용자를 차단하시겠습니까?',
    'ja': 'このユーザーをブロックしてもよろしいですか？',
  });

  static String get blockError => _t({
    'en': 'Could not block user',
    'es': 'No se pudo bloquear al usuario',
    'fr': 'Impossible de bloquer l\'utilisateur',
    'pt': 'Não foi possível bloquear o usuário',
    'de': 'Benutzer konnte nicht blockiert werden',
    'it': 'Impossibile bloccare l\'utente',
    'ru': 'Не удалось заблокировать пользователя',
    'ar': 'تعذر حظر المستخدم',
    'zh': '无法屏蔽用户',
    'ko': '사용자를 차단할 수 없습니다',
    'ja': 'ユーザーをブロックできませんでした',
  });

  static String get privacyUpdated => _t({
    'en': 'Privacy settings updated',
    'es': 'Ajustes de privacidad actualizados',
    'fr': 'Paramètres de confidentialité mis à jour',
    'pt': 'Configurações de privacidade atualizadas',
    'de': 'Datenschutzeinstellungen aktualisiert',
    'it': 'Impostazioni privacy aggiornate',
    'ru': 'Настройки конфиденциальности обновлены',
    'ar': 'تم تحديث إعدادات الخصوصية',
    'zh': '隐私设置已更新',
    'ko': '개인정보 설정이 업데이트되었습니다',
    'ja': 'プライバシー設定を更新しました',
  });

  static String get deletePhoto => _t({
    'en': 'Delete photo',
    'es': 'Eliminar foto',
    'fr': 'Supprimer la photo',
    'pt': 'Excluir foto',
    'de': 'Foto löschen',
    'it': 'Elimina foto',
    'ru': 'Удалить фото',
    'ar': 'حذف الصورة',
    'zh': '删除照片',
    'ko': '사진 삭제',
    'ja': '写真を削除',
  });

  static String get takePhoto => _t({
    'en': 'Take photo',
    'es': 'Tomar foto',
    'fr': 'Prendre une photo',
    'pt': 'Tirar foto',
    'de': 'Foto aufnehmen',
    'it': 'Scatta foto',
    'ru': 'Сделать фото',
    'ar': 'التقاط صورة',
    'zh': '拍照',
    'ko': '사진 찍기',
    'ja': '写真を撮る',
  });

  static String get adjustPhoto => _t({
    'en': 'Adjust photo',
    'es': 'Ajustar foto',
    'fr': 'Ajuster la photo',
    'pt': 'Ajustar foto',
    'de': 'Foto anpassen',
    'it': 'Regola foto',
    'ru': 'Настроить фото',
    'ar': 'تعديل الصورة',
    'zh': '调整照片',
    'ko': '사진 조정',
    'ja': '写真を調整',
  });

  static String get done => _t({
    'en': 'Done',
    'es': 'Listo',
    'fr': 'Terminé',
    'pt': 'Pronto',
    'de': 'Fertig',
    'it': 'Fatto',
    'ru': 'Готово',
    'ar': 'تم',
    'zh': '完成',
    'ko': '완료',
    'ja': '完了',
  });

  static String get next => _t({
    'en': 'Next',
    'es': 'Siguiente',
    'fr': 'Suivant',
    'pt': 'Próximo',
    'de': 'Weiter',
    'it': 'Avanti',
    'ru': 'Далее',
    'ar': 'التالي',
    'zh': '下一步',
    'ko': '다음',
    'ja': '次へ',
  });

  static String get back => _t({
    'en': 'Back',
    'es': 'Atrás',
    'fr': 'Retour',
    'pt': 'Voltar',
    'de': 'Zurück',
    'it': 'Indietro',
    'ru': 'Назад',
    'ar': 'رجوع',
    'zh': '返回',
    'ko': '뒤로',
    'ja': '戻る',
  });

  static String get stepOf => _t({
    'en': 'Step {current} of {total}',
    'es': 'Paso {current} de {total}',
    'fr': 'Étape {current} sur {total}',
    'pt': 'Passo {current} de {total}',
    'de': 'Schritt {current} von {total}',
    'it': 'Passo {current} di {total}',
    'ru': 'Шаг {current} из {total}',
    'ar': 'الخطوة {current} من {total}',
    'zh': '第 {current} 步，共 {total} 步',
    'ko': '{current}/{total} 단계',
    'ja': 'ステップ {current}/{total}',
  });

  static String get birthDate => _t({
    'en': 'When were you born?',
    'es': '¿Cuándo naciste?',
    'fr': 'Quand êtes-vous né ?',
    'pt': 'Quando você nasceu?',
    'de': 'Wann bist du geboren?',
    'it': 'Quando sei nato?',
    'ru': 'Когда вы родились?',
    'ar': 'متى ولدت؟',
    'zh': '你的出生日期？',
    'ko': '생년월일은 언제인가요?',
    'ja': '生年月日は？',
  });

  static String get genderSelect => _t({
    'en': 'What is your gender?',
    'es': '¿Cuál es tu sexo?',
    'fr': 'Quel est votre sexe ?',
    'pt': 'Qual é o seu sexo?',
    'de': 'Was ist dein Geschlecht?',
    'it': 'Qual è il tuo sesso?',
    'ru': 'Какой ваш пол?',
    'ar': 'ما هو جنسك؟',
    'zh': '你的性别？',
    'ko': '성별은 무엇인가요?',
    'ja': '性別は？',
  });

  static String get chooseUsername => _t({
    'en': 'Choose a username',
    'es': 'Elige un nombre de usuario',
    'fr': 'Choisissez un nom d\'utilisateur',
    'pt': 'Escolha um nome de usuário',
    'de': 'Wähle einen Benutzernamen',
    'it': 'Scegli un nome utente',
    'ru': 'Выберите имя пользователя',
    'ar': 'اختر اسم مستخدم',
    'zh': '选择用户名',
    'ko': '사용자 이름을 선택하세요',
    'ja': 'ユーザー名を選んでください',
  });

  static String get profilePhoto => _t({
    'en': 'Profile photo',
    'es': 'Foto de perfil',
    'fr': 'Photo de profil',
    'pt': 'Foto de perfil',
    'de': 'Profilfoto',
    'it': 'Foto profilo',
    'ru': 'Фото профиля',
    'ar': 'صورة الملف',
    'zh': '个人资料照片',
    'ko': '프로필 사진',
    'ja': 'プロフィール写真',
  });

  static String get male => _t({
    'en': 'Male',
    'es': 'Hombre',
    'fr': 'Homme',
    'pt': 'Homem',
    'de': 'Männlich',
    'it': 'Uomo',
    'ru': 'Мужской',
    'ar': 'ذكر',
    'zh': '男',
    'ko': '남성',
    'ja': '男性',
  });

  static String get female => _t({
    'en': 'Female',
    'es': 'Mujer',
    'fr': 'Femme',
    'pt': 'Mulher',
    'de': 'Weiblich',
    'it': 'Donna',
    'ru': 'Женский',
    'ar': 'أنثى',
    'zh': '女',
    'ko': '여성',
    'ja': '女性',
  });

  static String get other => _t({
    'en': 'Other',
    'es': 'Otro',
    'fr': 'Autre',
    'pt': 'Outro',
    'de': 'Anderes',
    'it': 'Altro',
    'ru': 'Другое',
    'ar': 'آخر',
    'zh': '其他',
    'ko': '기타',
    'ja': 'その他',
  });

  static String get tapToChange => _t({
    'en': 'Tap to change date',
    'es': 'Toca para cambiar fecha',
    'fr': 'Appuyez pour changer la date',
    'pt': 'Toque para alterar a data',
    'de': 'Zum Ändern des Datums tippen',
    'it': 'Tocca per cambiare data',
    'ru': 'Нажмите, чтобы изменить дату',
    'ar': 'اضغط لتغيير التاريخ',
    'zh': '点击更改日期',
    'ko': '날짜 변경하려면 탭하세요',
    'ja': 'タップして日付を変更',
  });

  static String get serverError => _t({
    'en': 'Server error',
    'es': 'Error del servidor',
    'fr': 'Erreur du serveur',
    'pt': 'Erro do servidor',
    'de': 'Serverfehler',
    'it': 'Errore del server',
    'ru': 'Ошибка сервера',
    'ar': 'خطأ في الخادم',
    'zh': '服务器错误',
    'ko': '서버 오류',
    'ja': 'サーバーエラー',
  });

  // == LOGIN & AUTH ==
  static String get signInGoogle => _t({
    'en': 'Continue with Google',
    'es': 'Continuar con Google',
    'fr': 'Continuer avec Google',
    'pt': 'Continuar com Google',
    'de': 'Mit Google fortfahren',
    'it': 'Continua con Google',
    'ru': 'Продолжить с Google',
    'ar': 'المتابعة مع Google',
    'zh': '使用 Google 继续',
    'ko': 'Google로 계속',
    'ja': 'Googleで続ける',
  });

  static String get connecting => _t({
    'en': 'Connecting...',
    'es': 'Conectando...',
    'fr': 'Connexion...',
    'pt': 'Conectando...',
    'de': 'Verbinde...',
    'it': 'Connessione...',
    'ru': 'Подключение...',
    'ar': 'جارٍ الاتصال...',
    'zh': '连接中...',
    'ko': '연결 중...',
    'ja': '接続中...',
  });

  static String get orWithEmail => _t({
    'en': 'or with email',
    'es': 'o con correo',
    'fr': 'ou avec email',
    'pt': 'ou com email',
    'de': 'oder mit E-Mail',
    'it': 'o con email',
    'ru': 'или по email',
    'ar': 'أو بالبريد الإلكتروني',
    'zh': '或使用邮箱',
    'ko': '또는 이메일로',
    'ja': 'またはメールで',
  });

  static String get enterEmail => _t({
    'en': 'Enter your email',
    'es': 'Ingresa tu correo',
    'fr': 'Entrez votre email',
    'pt': 'Digite seu email',
    'de': 'Gib deine E-Mail ein',
    'it': 'Inserisci la tua email',
    'ru': 'Введите ваш email',
    'ar': 'أدخل بريدك الإلكتروني',
    'zh': '输入你的邮箱',
    'ko': '이메일을 입력하세요',
    'ja': 'メールアドレスを入力',
  });

  static String get invalidEmail => _t({
    'en': 'Invalid email',
    'es': 'Correo inválido',
    'fr': 'Email invalide',
    'pt': 'Email inválido',
    'de': 'Ungültige E-Mail',
    'it': 'Email non valida',
    'ru': 'Неверный email',
    'ar': 'بريد إلكتروني غير صالح',
    'zh': '邮箱无效',
    'ko': '유효하지 않은 이메일',
    'ja': '無効なメールアドレス',
  });

  static String get emailLabel => _t({
    'en': 'Email',
    'es': 'Correo electrónico',
    'fr': 'Email',
    'pt': 'Email',
    'de': 'E-Mail',
    'it': 'Email',
    'ru': 'Эл. почта',
    'ar': 'البريد الإلكتروني',
    'zh': '电子邮箱',
    'ko': '이메일',
    'ja': 'メールアドレス',
  });

  static String get passwordLabel => _t({
    'en': 'Password',
    'es': 'Contraseña',
    'fr': 'Mot de passe',
    'pt': 'Senha',
    'de': 'Passwort',
    'it': 'Password',
    'ru': 'Пароль',
    'ar': 'كلمة المرور',
    'zh': '密码',
    'ko': '비밀번호',
    'ja': 'パスワード',
  });

  static String get enterPassword => _t({
    'en': 'Enter your password',
    'es': 'Ingresa tu contraseña',
    'fr': 'Entrez votre mot de passe',
    'pt': 'Digite sua senha',
    'de': 'Gib dein Passwort ein',
    'it': 'Inserisci la tua password',
    'ru': 'Введите ваш пароль',
    'ar': 'أدخل كلمة المرور',
    'zh': '输入你的密码',
    'ko': '비밀번호를 입력하세요',
    'ja': 'パスワードを入力',
  });

  static String get minChars => _t({
    'en': 'Minimum 6 characters',
    'es': 'Mínimo 6 caracteres',
    'fr': 'Minimum 6 caractères',
    'pt': 'Mínimo 6 caracteres',
    'de': 'Mindestens 6 Zeichen',
    'it': 'Minimo 6 caratteri',
    'ru': 'Минимум 6 символов',
    'ar': '6 أحرف على الأقل',
    'zh': '至少6个字符',
    'ko': '최소 6자',
    'ja': '6文字以上',
  });

  static String get forgotPassword => _t({
    'en': 'Forgot your password?',
    'es': '¿Has olvidado tu contraseña?',
    'fr': 'Mot de passe oublié ?',
    'pt': 'Esqueceu sua senha?',
    'de': 'Passwort vergessen?',
    'it': 'Password dimenticata?',
    'ru': 'Забыли пароль?',
    'ar': 'هل نسيت كلمة المرور؟',
    'zh': '忘记密码？',
    'ko': '비밀번호를 잊으셨나요?',
    'ja': 'パスワードをお忘れですか？',
  });

  static String get logIn => _t({
    'en': 'Log in',
    'es': 'Iniciar sesión',
    'fr': 'Se connecter',
    'pt': 'Entrar',
    'de': 'Anmelden',
    'it': 'Accedi',
    'ru': 'Войти',
    'ar': 'تسجيل الدخول',
    'zh': '登录',
    'ko': '로그인',
    'ja': 'ログイン',
  });

  static String get noAccount => _t({
    'en': 'Don\'t have an account? ',
    'es': '¿No tienes cuenta? ',
    'fr': 'Pas de compte ? ',
    'pt': 'Não tem conta? ',
    'de': 'Kein Konto? ',
    'it': 'Non hai un account? ',
    'ru': 'Нет аккаунта? ',
    'ar': 'ليس لديك حساب؟ ',
    'zh': '没有账户？',
    'ko': '계정이 없으신가요? ',
    'ja': 'アカウントをお持ちでないですか？ ',
  });

  static String get signUp => _t({
    'en': 'Sign up',
    'es': 'Regístrate',
    'fr': 'S\'inscrire',
    'pt': 'Cadastre-se',
    'de': 'Registrieren',
    'it': 'Registrati',
    'ru': 'Зарегистрироваться',
    'ar': 'اشتراك',
    'zh': '注册',
    'ko': '가입하기',
    'ja': '登録',
  });

  static String get createAccount => _t({
    'en': 'Create account',
    'es': 'Crear cuenta',
    'fr': 'Créer un compte',
    'pt': 'Criar conta',
    'de': 'Konto erstellen',
    'it': 'Crea account',
    'ru': 'Создать аккаунт',
    'ar': 'إنشاء حساب',
    'zh': '创建账户',
    'ko': '계정 만들기',
    'ja': 'アカウント作成',
  });

  static String get haveAccount => _t({
    'en': 'Already have an account? ',
    'es': '¿Ya tienes cuenta? ',
    'fr': 'Déjà un compte ? ',
    'pt': 'Já tem conta? ',
    'de': 'Bereits ein Konto? ',
    'it': 'Hai già un account? ',
    'ru': 'Уже есть аккаунт? ',
    'ar': 'هل لديك حساب بالفعل؟ ',
    'zh': '已有账户？',
    'ko': '이미 계정이 있으신가요? ',
    'ja': 'すでにアカウントをお持ちですか？ ',
  });

  static String get logInLink => _t({
    'en': 'Log in',
    'es': 'Inicia sesión',
    'fr': 'Connectez-vous',
    'pt': 'Entre',
    'de': 'Anmelden',
    'it': 'Accedi',
    'ru': 'Войдите',
    'ar': 'تسجيل الدخول',
    'zh': '登录',
    'ko': '로그인',
    'ja': 'ログイン',
  });

  // == PHONE & VERIFICATION ==
  static String get verificationCode => _t({
    'en': 'Verification code',
    'es': 'Código de verificación',
    'fr': 'Code de vérification',
    'pt': 'Código de verificação',
    'de': 'Bestätigungscode',
    'it': 'Codice di verifica',
    'ru': 'Код подтверждения',
    'ar': 'رمز التحقق',
    'zh': '验证码',
    'ko': '인증 코드',
    'ja': '確認コード',
  });

  static String get yourCodeIs => _t({
    'en': 'Your code is: ',
    'es': 'Tu código es: ',
    'fr': 'Votre code est : ',
    'pt': 'Seu código é: ',
    'de': 'Dein Code ist: ',
    'it': 'Il tuo codice è: ',
    'ru': 'Ваш код: ',
    'ar': 'رمزك هو: ',
    'zh': '你的验证码是：',
    'ko': '인증 코드: ',
    'ja': 'あなたのコード：',
  });

  static String get ok => _t({
    'en': 'OK',
    'es': 'OK',
    'fr': 'OK',
    'pt': 'OK',
    'de': 'OK',
    'it': 'OK',
    'ru': 'ОК',
    'ar': 'موافق',
    'zh': '确定',
    'ko': '확인',
    'ja': 'OK',
  });

  static String get enterNumber => _t({
    'en': 'Enter your number',
    'es': 'Ingresa tu número',
    'fr': 'Entrez votre numéro',
    'pt': 'Digite seu número',
    'de': 'Gib deine Nummer ein',
    'it': 'Inserisci il tuo numero',
    'ru': 'Введите ваш номер',
    'ar': 'أدخل رقمك',
    'zh': '输入你的号码',
    'ko': '번호를 입력하세요',
    'ja': '番号を入力',
  });

  static String get invalidNumber => _t({
    'en': 'Invalid number',
    'es': 'Número inválido',
    'fr': 'Numéro invalide',
    'pt': 'Número inválido',
    'de': 'Ungültige Nummer',
    'it': 'Numero non valido',
    'ru': 'Неверный номер',
    'ar': 'رقم غير صالح',
    'zh': '无效号码',
    'ko': '유효하지 않은 번호',
    'ja': '無効な番号',
  });

  static String get phoneNumber => _t({
    'en': 'Phone number',
    'es': 'Número de teléfono',
    'fr': 'Numéro de téléphone',
    'pt': 'Número de telefone',
    'de': 'Telefonnummer',
    'it': 'Numero di telefono',
    'ru': 'Номер телефона',
    'ar': 'رقم الهاتف',
    'zh': '电话号码',
    'ko': '전화번호',
    'ja': '電話番号',
  });

  static String get verify => _t({
    'en': 'Verify',
    'es': 'Verifícate',
    'fr': 'Vérifier',
    'pt': 'Verificar',
    'de': 'Bestätigen',
    'it': 'Verifica',
    'ru': 'Подтвердить',
    'ar': 'تحقق',
    'zh': '验证',
    'ko': '인증',
    'ja': '確認',
  });

  static String get enterCode => _t({
    'en': 'Enter code',
    'es': 'Introduce código',
    'fr': 'Entrez le code',
    'pt': 'Digite o código',
    'de': 'Code eingeben',
    'it': 'Inserisci codice',
    'ru': 'Введите код',
    'ar': 'أدخل الرمز',
    'zh': '输入验证码',
    'ko': '코드 입력',
    'ja': 'コードを入力',
  });

  static String get codeSent => _t({
    'en': 'A code was sent to your number',
    'es': 'Se envió un código a tu número',
    'fr': 'Un code a été envoyé à votre numéro',
    'pt': 'Um código foi enviado para seu número',
    'de': 'Ein Code wurde an deine Nummer gesendet',
    'it': 'È stato inviato un codice al tuo numero',
    'ru': 'Код отправлен на ваш номер',
    'ar': 'تم إرسال الرمز إلى رقمك',
    'zh': '验证码已发送到你的号码',
    'ko': '인증 코드가 번호로 전송되었습니다',
    'ja': 'コードがあなたの番号に送信されました',
  });

  static String get enter4DigitCode => _t({
    'en': 'Enter the 4-digit code',
    'es': 'Ingresa el código de 4 dígitos',
    'fr': 'Entrez le code à 4 chiffres',
    'pt': 'Digite o código de 4 dígitos',
    'de': 'Gib den 4-stelligen Code ein',
    'it': 'Inserisci il codice a 4 cifre',
    'ru': 'Введите 4-значный код',
    'ar': 'أدخل الرمز المكون من 4 أرقام',
    'zh': '输入4位验证码',
    'ko': '4자리 코드를 입력하세요',
    'ja': '4桁のコードを入力',
  });

  static String get verifyCode => _t({
    'en': 'Verify code',
    'es': 'Verificar código',
    'fr': 'Vérifier le code',
    'pt': 'Verificar código',
    'de': 'Code bestätigen',
    'it': 'Verifica codice',
    'ru': 'Подтвердить код',
    'ar': 'تأكيد الرمز',
    'zh': '验证码',
    'ko': '코드 확인',
    'ja': 'コードを確認',
  });

  static String get accountVerified => _t({
    'en': 'Account verified. Log in.',
    'es': 'Cuenta verificada. Inicia sesión.',
    'fr': 'Compte vérifié. Connectez-vous.',
    'pt': 'Conta verificada. Faça login.',
    'de': 'Konto verifiziert. Anmelden.',
    'it': 'Account verificato. Accedi.',
    'ru': 'Аккаунт подтверждён. Войдите.',
    'ar': 'تم التحقق من الحساب. سجل الدخول.',
    'zh': '账户已验证。请登录。',
    'ko': '계정이 인증되었습니다. 로그인하세요.',
    'ja': 'アカウントが確認されました。ログインしてください。',
  });

  // == RECORD ==
  static String get record => _t({
    'en': 'Record',
    'es': 'Grabar',
    'fr': 'Enregistrer',
    'pt': 'Gravar',
    'de': 'Aufnehmen',
    'it': 'Registra',
    'ru': 'Запись',
    'ar': 'تسجيل',
    'zh': '录制',
    'ko': '녹음',
    'ja': '録音',
  });

  static String get micPermission => _t({
    'en': 'Microphone permission required',
    'es': 'Permiso de micrófono requerido',
    'fr': 'Permission microphone requise',
    'pt': 'Permissão de microfone necessária',
    'de': 'Mikrofonberechtigung erforderlich',
    'it': 'Autorizzazione microfono richiesta',
    'ru': 'Требуется разрешение микрофона',
    'ar': 'إذن الميكروفون مطلوب',
    'zh': '需要麦克风权限',
    'ko': '마이크 권한이 필요합니다',
    'ja': 'マイクの許可が必要です',
  });

  static String get recordingReady => _t({
    'en': 'Recording ready',
    'es': 'Grabación lista',
    'fr': 'Enregistrement prêt',
    'pt': 'Gravação pronta',
    'de': 'Aufnahme bereit',
    'it': 'Registrazione pronta',
    'ru': 'Запись готова',
    'ar': 'التسجيل جاهز',
    'zh': '录制就绪',
    'ko': '녹음 준비 완료',
    'ja': '録音準備完了',
  });

  static String get lockedTapCheck => _t({
    'en': 'Locked - press ✓ to finish',
    'es': 'Bloqueado - pulsa ✓ para terminar',
    'fr': 'Verrouillé - appuyez sur ✓ pour terminer',
    'pt': 'Bloqueado - pressione ✓ para finalizar',
    'de': 'Gesperrt - drücke ✓ zum Beenden',
    'it': 'Bloccato - premi ✓ per terminare',
    'ru': 'Заблокировано - нажмите ✓ для завершения',
    'ar': 'مقفل - اضغط ✓ للإنهاء',
    'zh': '已锁定 - 按 ✓ 完成',
    'ko': '잠김 - ✓를 눌러 완료',
    'ja': 'ロック中 - ✓を押して終了',
  });

  static String get swipeUpToLock => _t({
    'en': 'Swipe up to lock',
    'es': 'Desliza arriba para bloquear',
    'fr': 'Balayez vers le haut pour verrouiller',
    'pt': 'Deslize para cima para bloquear',
    'de': 'Nach oben wischen zum Sperren',
    'it': 'Scorri verso l\'alto per bloccare',
    'ru': 'Проведите вверх для блокировки',
    'ar': 'اسحب لأعلى للقفل',
    'zh': '上滑锁定',
    'ko': '위로 스와이프하여 잠금',
    'ja': '上にスワイプしてロック',
  });

  static String get holdToRecord => _t({
    'en': 'Hold to record',
    'es': 'Mantén para grabar',
    'fr': 'Maintenez pour enregistrer',
    'pt': 'Segure para gravar',
    'de': 'Zum Aufnehmen gedrückt halten',
    'it': 'Tieni premuto per registrare',
    'ru': 'Удерживайте для записи',
    'ar': 'اضغط باستمرار للتسجيل',
    'zh': '按住录制',
    'ko': '길게 눌러 녹음',
    'ja': '長押しで録音',
  });

  static String get publish => _t({
    'en': 'Publish',
    'es': 'Publicar',
    'fr': 'Publier',
    'pt': 'Publicar',
    'de': 'Veröffentlichen',
    'it': 'Pubblica',
    'ru': 'Опубликовать',
    'ar': 'نشر',
    'zh': '发布',
    'ko': '게시',
    'ja': '公開',
  });

  static String get audioNotFound => _t({
    'en': 'Error: audio file not found',
    'es': 'Error: archivo de audio no encontrado',
    'fr': 'Erreur : fichier audio introuvable',
    'pt': 'Erro: arquivo de áudio não encontrado',
    'de': 'Fehler: Audiodatei nicht gefunden',
    'it': 'Errore: file audio non trovato',
    'ru': 'Ошибка: аудиофайл не найден',
    'ar': 'خطأ: ملف الصوت غير موجود',
    'zh': '错误：未找到音频文件',
    'ko': '오류: 오디오 파일을 찾을 수 없습니다',
    'ja': 'エラー：オーディオファイルが見つかりません',
  });

  // == PROFILE ==
  static String get followingLabel => _t({
    'en': 'Following',
    'es': 'Siguiendo',
    'fr': 'Abonnements',
    'pt': 'Seguindo',
    'de': 'Folge ich',
    'it': 'Seguiti',
    'ru': 'Подписки',
    'ar': 'يتابع',
    'zh': '关注中',
    'ko': '팔로잉',
    'ja': 'フォロー中',
  });

  static String get followersLabel => _t({
    'en': 'Followers',
    'es': 'Seguidores',
    'fr': 'Abonnés',
    'pt': 'Seguidores',
    'de': 'Follower',
    'it': 'Followers',
    'ru': 'Подписчики',
    'ar': 'المتابعون',
    'zh': '粉丝',
    'ko': '팔로워',
    'ja': 'フォロワー',
  });

  static String get noFollowing => _t({
    'en': 'No following',
    'es': 'No hay siguiendo',
    'fr': 'Aucun abonnement',
    'pt': 'Nenhum seguindo',
    'de': 'Keine Folgt',
    'it': 'Nessun seguito',
    'ru': 'Нет подписок',
    'ar': 'لا يوجد متابعة',
    'zh': '没有关注',
    'ko': '팔로잉 없음',
    'ja': 'フォロー中なし',
  });

  static String get noFollowers => _t({
    'en': 'No followers',
    'es': 'No hay seguidores',
    'fr': 'Aucun abonné',
    'pt': 'Nenhum seguidor',
    'de': 'Keine Follower',
    'it': 'Nessun follower',
    'ru': 'Нет подписчиков',
    'ar': 'لا يوجد متابعون',
    'zh': '没有粉丝',
    'ko': '팔로워 없음',
    'ja': 'フォロワーなし',
  });

  static String get userPlaceholder => _t({
    'en': 'User',
    'es': 'Usuario',
    'fr': 'Utilisateur',
    'pt': 'Usuário',
    'de': 'Benutzer',
    'it': 'Utente',
    'ru': 'Пользователь',
    'ar': 'مستخدم',
    'zh': '用户',
    'ko': '사용자',
    'ja': 'ユーザー',
  });

  // == NOTIFICATIONS ==
  static String get likedYourAudio => _t({
    'en': ' liked your audio',
    'es': ' le gustó tu audio',
    'fr': ' a aimé ton audio',
    'pt': ' curtiu seu áudio',
    'de': ' gefällt dein Audio',
    'it': ' ha messo mi piace al tuo audio',
    'ru': ' понравилось ваше аудио',
    'ar': ' أعجب بمقطعك الصوتي',
    'zh': '赞了你的音频',
    'ko': ' 회원님이 내 오디오를 좋아합니다',
    'ja': ' があなたのオーディオにいいねしました',
  });

  static String get commented => _t({
    'en': ' commented: ',
    'es': ' comentó: ',
    'fr': ' a commenté : ',
    'pt': ' comentou: ',
    'de': ' kommentierte: ',
    'it': ' ha commentato: ',
    'ru': ' прокомментировал(а): ',
    'ar': ' علّق: ',
    'zh': '评论了：',
    'ko': ' 댓글: ',
    'ja': ' がコメントしました：',
  });

  static String get startedFollowing => _t({
    'en': ' started following you',
    'es': ' empezó a seguirte',
    'fr': ' a commencé à vous suivre',
    'pt': ' começou a seguir você',
    'de': ' folgt dir jetzt',
    'it': ' ha iniziato a seguirti',
    'ru': ' начал(а) подписываться на вас',
    'ar': ' بدأ متابعتك',
    'zh': '开始关注你',
    'ko': ' 회원님이 나를 팔로우하기 시작했습니다',
    'ja': ' があなたをフォローし始めました',
  });

  static String get timeAgoMin => _t({
    'en': ' ago',
    'es': ' hace {time}',
    'fr': ' il y a {time}',
    'pt': ' há {time}',
    'de': ' vor {time}',
    'it': ' {time} fa',
    'ru': ' {time} назад',
    'ar': ' منذ {time}',
    'zh': '{time}前',
    'ko': ' {time} 전',
    'ja': '{time}前',
  });

  // == SEARCH / EMPTY STATES ==
  static String get noResults => _t({
    'en': 'No results',
    'es': 'Sin resultados',
    'fr': 'Aucun résultat',
    'pt': 'Sem resultados',
    'de': 'Keine Ergebnisse',
    'it': 'Nessun risultato',
    'ru': 'Нет результатов',
    'ar': 'لا توجد نتائج',
    'zh': '没有结果',
    'ko': '결과 없음',
    'ja': '結果がありません',
  });

  static String get search => _t({
    'en': 'Search',
    'es': 'Buscar',
    'fr': 'Rechercher',
    'pt': 'Buscar',
    'de': 'Suchen',
    'it': 'Cerca',
    'ru': 'Поиск',
    'ar': 'بحث',
    'zh': '搜索',
    'ko': '검색',
    'ja': '検索',
  });

  static String get loading => _t({
    'en': 'Loading...',
    'es': 'Cargando...',
    'fr': 'Chargement...',
    'pt': 'Carregando...',
    'de': 'Lädt...',
    'it': 'Caricamento...',
    'ru': 'Загрузка...',
    'ar': 'جارٍ التحميل...',
    'zh': '加载中...',
    'ko': '로딩 중...',
    'ja': '読み込み中...',
  });

  static String get save => _t({
    'en': 'Save',
    'es': 'Guardar',
    'fr': 'Enregistrer',
    'pt': 'Salvar',
    'de': 'Speichern',
    'it': 'Salva',
    'ru': 'Сохранить',
    'ar': 'حفظ',
    'zh': '保存',
    'ko': '저장',
    'ja': '保存',
  });

  static String get delete => _t({
    'en': 'Delete',
    'es': 'Eliminar',
    'fr': 'Supprimer',
    'pt': 'Excluir',
    'de': 'Löschen',
    'it': 'Elimina',
    'ru': 'Удалить',
    'ar': 'حذف',
    'zh': '删除',
    'ko': '삭제',
    'ja': '削除',
  });

  static String get send => _t({
    'en': 'Send',
    'es': 'Enviar',
    'fr': 'Envoyer',
    'pt': 'Enviar',
    'de': 'Senden',
    'it': 'Invia',
    'ru': 'Отправить',
    'ar': 'إرسال',
    'zh': '发送',
    'ko': '보내기',
    'ja': '送信',
  });

  static String get retry => _t({
    'en': 'Retry',
    'es': 'Reintentar',
    'fr': 'Réessayer',
    'pt': 'Tentar novamente',
    'de': 'Wiederholen',
    'it': 'Riprova',
    'ru': 'Повторить',
    'ar': 'إعادة المحاولة',
    'zh': '重试',
    'ko': '재시도',
    'ja': '再試行',
  });

  static String get info => _t({
    'en': 'Info',
    'es': 'Información',
    'fr': 'Info',
    'pt': 'Informação',
    'de': 'Info',
    'it': 'Info',
    'ru': 'Информация',
    'ar': 'معلومات',
    'zh': '信息',
    'ko': '정보',
    'ja': '情報',
  });

  static String get success => _t({
    'en': 'Success',
    'es': 'Éxito',
    'fr': 'Succès',
    'pt': 'Sucesso',
    'de': 'Erfolg',
    'it': 'Successo',
    'ru': 'Успех',
    'ar': 'نجاح',
    'zh': '成功',
    'ko': '성공',
    'ja': '成功',
  });

  static String get warning => _t({
    'en': 'Warning',
    'es': 'Advertencia',
    'fr': 'Avertissement',
    'pt': 'Aviso',
    'de': 'Warnung',
    'it': 'Attenzione',
    'ru': 'Предупреждение',
    'ar': 'تحذير',
    'zh': '警告',
    'ko': '경고',
    'ja': '警告',
  });

  static String get termsOfService => _t({
    'en': 'Terms of Service',
    'es': 'Términos del servicio',
    'fr': 'Conditions d\'utilisation',
    'pt': 'Termos de serviço',
    'de': 'Nutzungsbedingungen',
    'it': 'Termini di servizio',
    'ru': 'Условия обслуживания',
    'ar': 'شروط الخدمة',
    'zh': '服务条款',
    'ko': '서비스 약관',
    'ja': '利用規約',
  });

  static String get privacyPolicy => _t({
    'en': 'Privacy Policy',
    'es': 'Política de privacidad',
    'fr': 'Politique de confidentialité',
    'pt': 'Política de privacidade',
    'de': 'Datenschutzrichtlinie',
    'it': 'Informativa sulla privacy',
    'ru': 'Политика конфиденциальности',
    'ar': 'سياسة الخصوصية',
    'zh': '隐私政策',
    'ko': '개인정보 처리방침',
    'ja': 'プライバシーポリシー',
  });

  static String get audioRecents => _t({
    'en': 'No audios',
    'es': 'Sin audios',
    'fr': 'Pas d\'audio',
    'pt': 'Sem áudios',
    'de': 'Keine Audios',
    'it': 'Nessun audio',
    'ru': 'Нет аудио',
    'ar': 'لا توجد مقاطع صوتية',
    'zh': '没有音频',
    'ko': '오디오 없음',
    'ja': 'オーディオなし',
  });

  static String get welcomeMessage => _t({
    'en': 'Welcome to Audia! Your account is set up.',
    'es': '¡Bienvenido a Audia! Tu cuenta está configurada.',
    'fr': 'Bienvenue sur Audia ! Votre compte est configuré.',
    'pt': 'Bem-vindo ao Audia! Sua conta está configurada.',
    'de': 'Willkommen bei Audia! Dein Konto ist eingerichtet.',
    'it': 'Benvenuto su Audia! Il tuo account è configurato.',
    'ru': 'Добро пожаловать в Audia! Ваш аккаунт настроен.',
    'ar': 'مرحباً بك في Audia! تم إعداد حسابك.',
    'zh': '欢迎来到 Audia！你的账户已设置完成。',
    'ko': 'Audia에 오신 것을 환영합니다! 계정이 설정되었습니다.',
    'ja': 'Audiaへようこそ！アカウントが設定されました。',
  });

  static String get completeStepPrompt => _t({
    'en': 'Please complete this step',
    'es': 'Por favor completa este paso',
    'fr': 'Veuillez compléter cette étape',
    'pt': 'Por favor, complete esta etapa',
    'de': 'Bitte vervollständige diesen Schritt',
    'it': 'Per favore completa questo passaggio',
    'ru': 'Пожалуйста, завершите этот шаг',
    'ar': 'يرجى إكمال هذه الخطوة',
    'zh': '请完成此步骤',
    'ko': '이 단계를 완료해 주세요',
    'ja': 'このステップを完了してください',
  });

  static String get updateError => _t({
    'en': 'could not update',
    'es': 'no se pudo actualizar',
    'fr': 'impossible de mettre à jour',
    'pt': 'não foi possível atualizar',
    'de': 'konnte nicht aktualisiert werden',
    'it': 'impossibile aggiornare',
    'ru': 'не удалось обновить',
    'ar': 'تعذر التحديث',
    'zh': '无法更新',
    'ko': '업데이트할 수 없습니다',
    'ja': '更新できませんでした',
  });

  static String get lastMessage => _t({
    'en': 'Last message...',
    'es': 'Último mensaje...',
    'fr': 'Dernier message...',
    'pt': 'Última mensagem...',
    'de': 'Letzte Nachricht...',
    'it': 'Ultimo messaggio...',
    'ru': 'Последнее сообщение...',
    'ar': 'آخر رسالة...',
    'zh': '最后消息...',
    'ko': '마지막 메시지...',
    'ja': '最後のメッセージ...',
  });

  static String get noData => _t({
    'en': 'No {label}',
    'es': 'No hay {label}',
    'fr': 'Aucun {label}',
    'pt': 'Nenhum {label}',
    'de': 'Keine {label}',
    'it': 'Nessun {label}',
    'ru': 'Нет {label}',
    'ar': 'لا يوجد {label}',
    'zh': '没有{label}',
    'ko': '{label} 없음',
    'ja': '{label}がありません',
  });

  static String get followingUser => _t({
    'en': 'Following {user}',
    'es': 'Siguiendo a {user}',
    'fr': 'Vous suivez {user}',
    'pt': 'Seguindo {user}',
    'de': 'Folge {user}',
    'it': 'Segui {user}',
    'ru': 'Подписан на {user}',
    'ar': 'تتابع {user}',
    'zh': '已关注 {user}',
    'ko': '{user}님을 팔로우합니다',
    'ja': '{user}をフォロー中',
  });

  static String get unfollowedUser => _t({
    'en': 'Unfollowed {user}',
    'es': 'Dejaste de seguir a {user}',
    'fr': 'Vous ne suivez plus {user}',
    'pt': 'Deixou de seguir {user}',
    'de': '{user} nicht mehr gefolgt',
    'it': 'Hai smesso di seguire {user}',
    'ru': 'Отписался от {user}',
    'ar': 'ألغيت متابعة {user}',
    'zh': '已取消关注 {user}',
    'ko': '{user}님을 언팔로우했습니다',
    'ja': '{user}のフォローを解除',
  });

  static String get profileOf => _t({
    'en': '{user}\'s profile',
    'es': 'Perfil de {user}',
    'fr': 'Profil de {user}',
    'pt': 'Perfil de {user}',
    'de': 'Profil von {user}',
    'it': 'Profilo di {user}',
    'ru': 'Профиль {user}',
    'ar': 'ملف {user}',
    'zh': '{user}的资料',
    'ko': '{user}님의 프로필',
    'ja': '{user}のプロフィール',
  });

  static String get timeAgoNow => _t({
    'en': 'just now',
    'es': 'ahora mismo',
    'fr': 'à l\'instant',
    'pt': 'agora mesmo',
    'de': 'gerade eben',
    'it': 'proprio ora',
    'ru': 'только что',
    'ar': 'الآن',
    'zh': '刚刚',
    'ko': '방금',
    'ja': 'たった今',
  });

  static String get timeAgoMinFormat => _t({
    'en': '{n}m ago',
    'es': 'hace {n}m',
    'fr': 'il y a {n}m',
    'pt': 'há {n}m',
    'de': 'vor {n}m',
    'it': '{n}m fa',
    'ru': '{n}м назад',
    'ar': 'منذ {n}د',
    'zh': '{n}分钟前',
    'ko': '{n}분 전',
    'ja': '{n}分前',
  });

  static String get timeAgoHourFormat => _t({
    'en': '{n}h ago',
    'es': 'hace {n}h',
    'fr': 'il y a {n}h',
    'pt': 'há {n}h',
    'de': 'vor {n}h',
    'it': '{n}h fa',
    'ru': '{n}ч назад',
    'ar': 'منذ {n}س',
    'zh': '{n}小时前',
    'ko': '{n}시간 전',
    'ja': '{n}時間前',
  });

  static String get timeAgoDayFormat => _t({
    'en': '{n}d ago',
    'es': 'hace {n}d',
    'fr': 'il y a {n}j',
    'pt': 'há {n}d',
    'de': 'vor {n}t',
    'it': '{n}g fa',
    'ru': '{n}д назад',
    'ar': 'منذ {n}أ',
    'zh': '{n}天前',
    'ko': '{n}일 전',
    'ja': '{n}日前',
  });

  static String get friendN => _t({
    'en': 'Friend {n}',
    'es': 'Amigo {n}',
    'fr': 'Ami {n}',
    'pt': 'Amigo {n}',
    'de': 'Freund {n}',
    'it': 'Amico {n}',
    'ru': 'Друг {n}',
    'ar': 'صديق {n}',
    'zh': '朋友 {n}',
    'ko': '친구 {n}',
    'ja': '友達 {n}',
  });

  static String get notificationLikedAudio => _t({
    'en': '{user} liked your audio',
    'es': 'A {user} le gustó tu audio',
    'fr': '{user} a aimé ton audio',
    'pt': '{user} curtiu seu áudio',
    'de': '{user} gefällt dein Audio',
    'it': 'A {user} piace il tuo audio',
    'ru': '{user} понравилось ваше аудио',
    'ar': 'أعجب {user} بمقطعك الصوتي',
    'zh': '{user}赞了你的音频',
    'ko': '{user}님이 회원님의 오디오를 좋아합니다',
    'ja': '{user}があなたのオーディオにいいねしました',
  });

  static String get notificationCommented => _t({
    'en': '{user} commented: {comment}',
    'es': '{user} comentó: {comment}',
    'fr': '{user} a commenté : {comment}',
    'pt': '{user} comentou: {comment}',
    'de': '{user} kommentierte: {comment}',
    'it': '{user} ha commentato: {comment}',
    'ru': '{user} прокомментировал: {comment}',
    'ar': 'علق {user}: {comment}',
    'zh': '{user}评论了：{comment}',
    'ko': '{user}님 댓글: {comment}',
    'ja': '{user}がコメントしました：{comment}',
  });

  static String get notificationStartedFollowing => _t({
    'en': '{user} started following you',
    'es': '{user} empezó a seguirte',
    'fr': '{user} a commencé à vous suivre',
    'pt': '{user} começou a seguir você',
    'de': '{user} folgt dir jetzt',
    'it': '{user} ha iniziato a seguirti',
    'ru': '{user} начал(а) подписываться на вас',
    'ar': 'بدأ {user} متابعتك',
    'zh': '{user}开始关注你',
    'ko': '{user}님이 나를 팔로우하기 시작했습니다',
    'ja': '{user}があなたをフォローし始めました',
  });

  static String get month1 => _t({
    'en': 'January', 'es': 'Enero', 'fr': 'Janvier', 'pt': 'Janeiro',
    'de': 'Januar', 'it': 'Gennaio', 'ru': 'Январь', 'ar': 'يناير',
    'zh': '一月', 'ko': '1월', 'ja': '1月',
  });
  static String get month2 => _t({
    'en': 'February', 'es': 'Febrero', 'fr': 'Février', 'pt': 'Fevereiro',
    'de': 'Februar', 'it': 'Febbraio', 'ru': 'Февраль', 'ar': 'فبراير',
    'zh': '二月', 'ko': '2월', 'ja': '2月',
  });
  static String get month3 => _t({
    'en': 'March', 'es': 'Marzo', 'fr': 'Mars', 'pt': 'Março',
    'de': 'März', 'it': 'Marzo', 'ru': 'Март', 'ar': 'مارس',
    'zh': '三月', 'ko': '3월', 'ja': '3月',
  });
  static String get month4 => _t({
    'en': 'April', 'es': 'Abril', 'fr': 'Avril', 'pt': 'Abril',
    'de': 'April', 'it': 'Aprile', 'ru': 'Апрель', 'ar': 'أبريل',
    'zh': '四月', 'ko': '4월', 'ja': '4月',
  });
  static String get month5 => _t({
    'en': 'May', 'es': 'Mayo', 'fr': 'Mai', 'pt': 'Maio',
    'de': 'Mai', 'it': 'Maggio', 'ru': 'Май', 'ar': 'مايو',
    'zh': '五月', 'ko': '5월', 'ja': '5月',
  });
  static String get month6 => _t({
    'en': 'June', 'es': 'Junio', 'fr': 'Juin', 'pt': 'Junho',
    'de': 'Juni', 'it': 'Giugno', 'ru': 'Июнь', 'ar': 'يونيو',
    'zh': '六月', 'ko': '6월', 'ja': '6月',
  });
  static String get month7 => _t({
    'en': 'July', 'es': 'Julio', 'fr': 'Juillet', 'pt': 'Julho',
    'de': 'Juli', 'it': 'Luglio', 'ru': 'Июль', 'ar': 'يوليو',
    'zh': '七月', 'ko': '7월', 'ja': '7月',
  });
  static String get month8 => _t({
    'en': 'August', 'es': 'Agosto', 'fr': 'Août', 'pt': 'Agosto',
    'de': 'August', 'it': 'Agosto', 'ru': 'Август', 'ar': 'أغسطس',
    'zh': '八月', 'ko': '8월', 'ja': '8月',
  });
  static String get month9 => _t({
    'en': 'September', 'es': 'Septiembre', 'fr': 'Septembre', 'pt': 'Setembro',
    'de': 'September', 'it': 'Settembre', 'ru': 'Сентябрь', 'ar': 'سبتمبر',
    'zh': '九月', 'ko': '9월', 'ja': '9月',
  });
  static String get month10 => _t({
    'en': 'October', 'es': 'Octubre', 'fr': 'Octobre', 'pt': 'Outubro',
    'de': 'Oktober', 'it': 'Ottobre', 'ru': 'Октябрь', 'ar': 'أكتوبر',
    'zh': '十月', 'ko': '10월', 'ja': '10月',
  });
  static String get month11 => _t({
    'en': 'November', 'es': 'Noviembre', 'fr': 'Novembre', 'pt': 'Novembro',
    'de': 'November', 'it': 'Novembre', 'ru': 'Ноябрь', 'ar': 'نوفمبر',
    'zh': '十一月', 'ko': '11월', 'ja': '11月',
  });
  static String get month12 => _t({
    'en': 'December', 'es': 'Diciembre', 'fr': 'Décembre', 'pt': 'Dezembro',
    'de': 'Dezember', 'it': 'Dicembre', 'ru': 'Декабрь', 'ar': 'ديسمبر',
    'zh': '十二月', 'ko': '12월', 'ja': '12月',
  });
}
