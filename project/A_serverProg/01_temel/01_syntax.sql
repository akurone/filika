/*markdown
## beni bi' oku
- bir objenin _body_'si bir _string_'den ibaret; dolayısıyla düzgün bir şekilde "tırnaklanması" gerek. _dollar quoting_ en akı(l)cı çözüm (kim uğraşır 'içinde' _escape_ ile).
- bir sürü dilden dilediğini (ve ortamda hazır olanı) _body_'nin başında ya da sonunda `language` ile belirterek kullanabilirsin.
- parametrelere isimle ya da ($ ön ekli ve 1'den başlayan) pozisyonla erişebilirsin ($0 dönüş değeri, onun için 1'den başlamışlar, VB lobisinin burada ne hükmü olabilir?).
- parametre değerleri `default` ya da `=` ile opsiyonel olabilir. hatta parametre adı vermesen de olur!
- `;` satır sonlandırma için kullanılıyor lakin `declare`, `begin` ve `loop` gibi bazı hatırlı satırları sonlandırmaya çalışmak sağlığa zararlı.
- `PLPGSQL` _block_ (buradaki `begin`/`end;` ifadeleri sadece gruplama amaçlı _transaction_ ile ilgisi yok) tabanlı, bloklar _label_ ile etiketlenebilir, ama biz etiketlemeyeceğiz. `PLPGSQL` ile yazılan bir objenin _body_'si bir blok olmalı ama `SQL` için böyle değil. blokları gerçekten matruşka gibi iç-içe gömebilir, içeride hata yakalayabilirsin, yeri gelince bakacağız.
- BÜYÜKHARF zorunlu değil, hatta ortam _CaSeInSeNsItiVe_ ama _küçük harf_ konusunda ısrar edenlerin dişleri erkenden çürüyormuş ona göre.
- `create or replace` ile kendi hayatınızı kolaylaştırıp başkalarının hayatına heyecan katabilirsin: `x(a int)` objesini `x(a int, b int = null)` şeklinde opsiyonel bir parametre ile _zenginleştirmek_ (ya da tam tersi, gereksiz parametre(leri) atıp _sadeleştirmek_) istiyorsan PG mevcut `x(a int)` objesini değiştirmek yerine yeni imza (isim + parametre(ler)) ile bir obje daha oluşturacak.
**yani** `or replace` için isim=isim değil imza=imza şeklinde bir eşitlik olmalı. "gayet doğal, neden bu kadar abarttın" dersen: ağaçtan düşmeyen beni anlamaz!!
*/

/*markdown
## örnek a:
*/

create or replace function ornek_a(a int, b int, c int = 1)
returns int
language sql
as $$
  select $1 * b * c;
$$;

/*markdown
- \$$ ile ilk _dollar quoting_'imizi yaptık, bunun bir de arası işlemeli _dollar dürümming_ versiyonu var, sonraki örnekte onu kullanacağız.
- `a` parametresine `$1` ile eriştik, çok geçerli bir nedenin yoksa böyle yapma bence, kendine küsebilirsin sonra.
- dil bu örnekte `SQL`, görüldüğü gibi blok yok! acaba `select` yerine `:=` gibi atama yapıp değer dönebilir miydik? _notebook_'la çalışmanın en güzel yanı bu: birkaç satır yukarıda bedavaya deneyebilirsin!
*/

/*markdown
## örnek b:
*/

create or replace function ornek_b(a int, 
  /*aklına parametre adı mı gelmedi? boşver!*/ int, c int default 1)
returns int
as $IsteyenBuraya5KereSekerAdamBileYazabilirGorursenSasirmaDiyeSoyluyorum$
begin
  return a * $2 * c;
  begin
    /*
    blok blok içinde
    yorum blok içinde
    sayı sıfıra bölünmez diyenler
    aşağıdaki satırın şaşkınlığı içinde!
    */
    return 1/0;
  end;
end;
--sekerAdamla başlayan sekerAdamla bitirsin yoksa şeker adam rüyalarına girer!!
$IsteyenBuraya5KereSekerAdamBileYazabilirGorursenSasirmaDiyeSoyluyorum$
language plpgsql;

/*markdown
- _inline_, tek ve çok satır yorumların nasıl kullanıldığını gördüğümüze göre, artık _parser_'ın bile kod okumadığı bir çağda yorumların kodu nasıl okunaklı kıldığına dair yorumlarınızı aşağıya bekliyorum:)
- bu örnektekinin bir anlamı olmasa da blok içinde blok kullandık.
- \$dürüm\$ yaptık, \$dürüm\$'le başlayıp \$künefe\$ ile bitirmeye kalkmadığın sürece sorun yok.
*/

/*markdown
## çalıştıralım:
*/

select 
  ornek_a(0, 1) + ornek_b(2, 3, 4) "bence-tüm-sütun-adları-kebab-case ""OLMALI"""
, ornek_a(5, 6, 7) as NedirKuzumSizinBuCaseTakintiniz;

select * from ornek_a(8, 9) as f(sutun1);
select * from ornek_a(10, 11) f(as_opsiyonel);

/*markdown
mühim bir işlem yapmadık dolayısıyla çıktılar da şahane olmayacak ama iki örnek arasındaki yazım farkı bu ünitenin ana teması zaten:) bir de;
- " içinde isimlendirmeyi istediğin gibi yapabilirsin.
- _alias_ konusunda PG çok yetenekli: `f(sutun1)` ile `from`'da kullanılan fonksiyonun sütunlarına isim verebilirsin, bunu yapmak zorunda kalacağın durumlar da olacak; göreceğiz.
*/

/*markdown
## etrafı temizleyelim:
*/

drop function if exists ornek_a;
drop function if exists ornek_b;