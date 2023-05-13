/*markdown
# hoş geldin!
birazdan (belki de az önce) "neden metodolojik natüralizm yerine bu sarkastik futbol yorumcusunun voleybol maçı anlatım üslubu?" sorusu aklına geleceği için cevabı peşin vereyim: üslup konusunda nasıl olsa anlaşamayız; ben içimden geldiği gibi yazayım, sen içinden geldiği gibi oku. 
## sana hitap ediyor mu?
- ingilizce biliyorsan ("bana kadar" ya da "google bunu yanlış mı çevirmiş, bi' kendim bakayım" seviyesi yeterli),
- biraz programlama geçmişin varsa: prosedür, fonksiyon, değişken vb. ifadeler kulağını tırmalamıyorsa,
- Codd amcayı tanımana gerek yok ama ilişkisel veri tabanı nedir biliyorsan,
- bu fili (PG) benim gibi yeni tanıyorsan sana faydası olabilir.
- ayrıca [mükerrem teyzeye](https://www.youtube.com/watch?v=erEXERGN80o) geçmiş olsun dileklerimi takdim ederken Kral Richard'ın yaklaşık 6 dakika boyunca muhabire tane tane anlattığı olguya dikkatinizi çekerek aradaki boşluklara dikkat etmenizi tavsiye ederim: benim (senin _x_ konusunu bildiğine dair) varsayımlarım seni darlamasın, boşluk varsa doldurmadan devam etme.
## plan nedir?
olabildiğince kısa-öz ve atıfla gitmek: [2900 civarı](https://www.postgresql.org/docs/) sayfa belge yazılmış zaten, hepsini adam akıllı okumak bile haftalar alır. benim perspektifimden önemli noktaların <u>altını çizip</u> senin yolculuğunu biraz kolaylaştırmayı umuyorum sadece.
## ufaktan başlayalım:
- PG için fonksiyon ve prosedür aralarında 15 yaş olan iki kardeş gibi, prosedür bayaa sonra geldiğinden fonksiyon o arada ziyadesiyle serpilmiş. fonksiyon üzerinde yoğunlaşıp prosedürün farklı olduğu yerleri göstermek daha kolay olacak gibi geliyor ama yaşayıp göreceğiz. dolayısıyla **obje** gördüğün yerde fonksiyon ya da prosedür düşünebilirsin.
- sadece ilişkisel değil _object-relational_ kategorisinde bir DBMS bu: _object_ kısmı süper duruyor ama gerçek hayatta ne derece faydalı olur, sınırları nedir tecrübe etmedim (mesela _array_ gibi DBMS camiasında boynu bükük gezen kavramlar burada 1. sınıf vatandaş. lakin "bir sütunu _array_ olarak tanımlayabiliyorsan, tanımlamalı mısın?" sorusu dediğim gibi bende hala cevapsız).
- gayet esnek, _extension_ yapısı ile neredeyse her şey ikame edilebiliyor: evden _index_, dil (_js_, _python_ vb.) gibi çok temel bileşenleri bile getirip ekleyebiliyorsun.
- burada ana dilimiz `PLPGSQL`, istisnası olduğu yerde bahsederiz.
*/