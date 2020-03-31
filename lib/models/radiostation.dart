class RadioStation {
  String stationName;
  String iconUrl;
  String bigIconUrl;
  List<dynamic> stationPhotos;
  String history;
  double latitude;
  double longitude;
  String newsRss;
  String streamUrl;
  String facebookUrl;
  String twitterUrl;

  RadioStation.base()
      :
        stationName = "CUAC FM",
        iconUrl = "https://pbs.twimg.com/profile_images/1058369132004028416/KVRpQGQU_400x400.jpg",
        bigIconUrl = "https://pbs.twimg.com/profile_images/1058369132004028416/KVRpQGQU_400x400.jpg",
        stationPhotos = [ "https://cuacfm.org/wp-content/uploads/2015/04/alexandreb%C3%B3veda.jpg",
        "https://cuacfm.org/wp-content/uploads/2015/04/akustikel.jpg",
        "https://cuacfm.org/wp-content/uploads/2015/04/highfreq.jpg",
        "https://cuacfm.org/wp-content/uploads/2015/04/mesagrabaci%C3%B3n.jpg",
        "https://i1.wp.com/cuacfm.org/wp-content/uploads/2017/09/CUAC_ASAMBLEA_PECHEFM02.jpg",
        "https://cuacfm.org/wp-content/uploads/2015/04/cousomicros1.jpg",
        "http://fotos00.laopinioncoruna.es/2015/12/10/646x260/cuac-fm.jpg"],
        history = "<h3>Benvid@ a radio comunitaria da Coruña.</h3><p>Cuac FM é unha radio comunitaria. Unha radio comunitaria é unha emisora privada, sen ánimo de lucro, que ten un fin social: garantir o exercicio do dereito de acceso á comunicación e a liberdade de expresión da cidadanía.</p><img src=\"https://cuacfm.org/wp-content/uploads/2016/05/equipo-cuacfm-ciencia-en-la-calle-2016.jpg\" alt=\"Smiley face\"><br/><p>Diríxese e débese á comunidade, cumpre unha finalidade social e está aberta á participación o máis ampla posible respecto á propiedade do medio e o acceso á emisión, así coma ás diversas decisións de programación, administración, financiamento e avaliación, que non ten fins de lucro e que non realiza proselitismo relixioso nin partidista.</p><img src=\"https://i1.wp.com/cuacfm.org/wp-content/uploads/2015/05/asamblea-cuac.jpg?w=886&ssl=1\" alt=\"Smiley face\"><br/><p>En CUAC FM participan persoas físicas e xurídicas, funciona dun xeito participativo e horizontal, a través da asemblea, das coordenadoras e dos grupos de traballo. Todo o que facemos en CUAC FM facémolo dende a colaboración e o voluntariado. Non hai xefes nin persoal contratado. </p><img src=\"http://fotos00.laopinioncoruna.es/2015/12/10/646x260/cuac-fm.jpg\" alt=\"Smiley face\"><br/><p>CUAC FM emitindo no 103.4 FM desde 1996. Se tes interés en facer un programa de radio contacta a través do correo electrónico e te mandaremos a información.<br/><br/><a href=\"mailto:comunicacion@cuacfm.org\">comunicacion@cuacfm.org</a></p><img src=\"https://cuacfm.org/wp-content/uploads/2015/04/alexandreb%C3%B3veda.jpg\" alt=\"Smiley face\">",
        latitude = 43.327552,
        longitude = -8.4090277,
        newsRss = "https://cuacfm.org/feed/",
        streamUrl = "http://streaming.cuacfm.org/cuacfm.mp3",
        facebookUrl = "https://www.facebook.com/cuacfm/",
        twitterUrl = "https://twitter.com/cuacfm/";

  RadioStation.fromInstance(Map<String, dynamic> map)
      :
        stationName = map["station_name"],
        iconUrl = map["icon_url"],
        bigIconUrl = map["big_icon_url"],
        stationPhotos = map["station_photos"],
        history = map["history"],
        latitude = map["latitude"],
        longitude = map["longitude"],
        newsRss = map["news_rss"],
        streamUrl = map["stream_url"],
        facebookUrl = map["facebook_url"],
        twitterUrl = map["twitter_url"];
}