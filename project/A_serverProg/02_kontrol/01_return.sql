/*markdown
## işler hızla karışacak, iyi takip edin
- **tek** bir _scalar_ değeri _çağırana_ geri göndermek için (`return ifade;` şeklinde) zaten _return_ kullandık.
- bunun dışında prosedürlerde ve dönüş tipinin `void` tanımlandığı fonksiyonlarda `return;` olarak kullanılabilir. (arada sadece `ifade`'nin eksildiğini fark ettin sanırım, işte `void` tipinin tek meşru değeri `ifade` yerine yazdığımız _şey_: hiçbir şey!) "prosedür dediğin de zaten `void` dönen fonksiyon değildir de nedir" diye bir trida başlayacaktım ama gerisi gelmedi.
- bu arada _scalar_ için sadece primatlar aklına gelmesin: _composite type_ candır (_user defined type_ hariç).
- fonksiyonu `returns setof ...` şeklinde tanımlayıp `return next` ile döngü tadında, `return query` ile küme tadında birden fazla **satır** geri dönebilirsin. bir fonksiyonu **tablo** gibi kullanabilmek çok büyük bir yetenek ama [_docs_'dan](https://www.postgresql.org/docs/15/plpgsql-control-structures.html#:~:text=FROM%20get_available_flightid(CURRENT_DATE)%3B-,Note,-The%20current%20implementation) anladığım kadarıyla mevcut (v15) implementasyon biraz hantal.
  - _t-sql_'ciler: _table valued function_ biraderlerden dahi olan (_single statement_) değil canavar olana (_multi stament_) benziyor.
  - _oop_'ciler: iteratör kurup _yield_ yapMIyor, tüm _result set_'i biriktiriyor.
  > bir de [SQL dili](https://www.postgresql.org/docs/current/xfunc-sql.html#XFUNC-SQL-TABLE-FUNCTIONS) içinde  de benzer yapılar mevcut; yukarıdaki bahis `PLPGSQL` ile ilgili. lakin aradığın parametre alabilen bir _view_ gibi basit ama (_single statement tvf_ gibi) güçlü bir şeyse (implementasyon detayını pek bilmesem de) _SQL_ tarafı sanki daha uygun görünüyor (yani: acayip sıkıyorum şu an:)).
  - bu arada PG _scalar_ değer dönen bir fonksiyonu _from_'da kullandığınızda **da** naz yapmıyor, burada önemli nokta fonksiyonun "tablo gibi" birden fazla satır dönebiliyor olması.
- `return query execute` kombosu da mevcut, _binding_ vb. işlerde [execute](0402_loop_sorgu.sql) gibi davranıyor.
- fonksiyonda _out_ parametre tanımlayıp `returns setof record` dersen ... dur! efendi gibi _table_ dön.
***
fazlasıyla _scalar_ örneğimiz mevcut; direkt _next_/_query_ konularına dalıyoruz!
*/

/*markdown
## örnek next:
*/

create or replace function ornek_next()
returns setof record
language plpgsql
as $$
declare
x record;
begin
  for x in select * from public.actor limit 3
  loop
    return next (x.actor_id, x.first_name);
  end loop;  
  return;
end;
$$;

/*markdown
### bakıyoruz:
- _setof record_ döneceğimizi söyledik, artık hangi sütunları hangi tipte döndüğümüzü bilmek çağıranın problemi. evet, _record_ güzel ama yerinde kullanılmalı: bunun gibi bir fonksiyonu _from_ içinde çağırırken mutlaka _alias_ ile tüm sütunlara ad ve doğru tip vermek lazım (istersen f _alias_'ını silip aşağıdaki _select_'i çalıştırmayı bir dene).
- _loop_ içinde (önceden) x adıyla deklare ettiğimiz _record_ (ki bunu _actor_ tablosunun _rowtype_'ı olarak da tanımlayabilirdik, denesene!) tipindeki değişkene satırı atadıktan sonra bu satırın sadece 2 sütununu içeren **başka** bir _record_ tipindeki (gizli diyelim havalı olsun) bir değişkeni her şey bittiğinde geri dönülecek _result set_'e ekliyoruz.
- _loop_ bittikten sonraki `return;` olmasa da olur ama bu haliyle bu yapının nasıl çalıştığını görmeye faydası var: program oraya gelene kadar çağırana bir şey _dönmedi_, hafızada biriktirdiklerini şimdi **dönüyor**.
- ama "bunun _return_ tipi _void_ değil, o sondaki neden sadece `return;`" araştır bakalım.
*/

select * from ornek_next() f(a int, b text);

/*markdown
## örnek query:
*/

create or replace function ornek_query(x int)
returns table (a int, b text)
language plpgsql
as $$
begin
  return query 
  select t.actor_id, t.first_name
  from public.actor t 
  where 1 = x
  limit 3;
  if not found then
    raise exception 'hala fonksiyonun içindeyim!!';
  end if;
  return;
end;
$$;

/*markdown
### buna da bakıyoruz:
- _setof_ yerine verdiğimiz sütunlar (ve tipleriyle) bir _table_ döndüğümüzü ifade ettik. artık çağıranın hayatı daha kolay, oley!
- `found` değişkeni bir önceki sorgunun akıbetini söyleyen bir [ajan:)](https://www.postgresql.org/docs/current/plpgsql-statements.html#PLPGSQL-STATEMENTS-DIAGNOSTICS). bunu kullanıp aşağıdaki 2. _select_'in hata almasını sağlıyoruz.
- en son _return;_ yine opsiyonel, mevzu pekişsin diye orada.
*/

select * from ornek_query(1);

select * from ornek_query(0);

/*markdown
## etrafı temizleyelim:
*/

drop function if exists ornek_next;
drop function if exists ornek_query;