/*markdown
## evet biraz karışık, ben de tam anlamadım :(
PG (muhatap olduğum) diğer DBMS'lerden biraz farklı ele alıyor konuyu (temel _transaction_ mantığından bahsetmiyorum, `plpgsql` içindeki kullanımdan bahsediyorum):
- blok içinde [exception](https://www.postgresql.org/docs/15/plpgsql-transactions.html#:~:text=A%20transaction%20cannot%20be%20ended%20inside%20a%20block%20with%20exception%20handlers.) kısmı varsa `commit`/`rollback` kullanamıyorsun (mu? uyduruyor da olabilirim!), [anladığım kadarıyla](https://www.postgresql.org/docs/15/plpgsql-control-structures.html#:~:text=When%20an%20error%20is%20caught%20by%20an%20EXCEPTION%20clause%2C%20the%20local%20variables%20of%20the%20PL/pgSQL%20function%20remain%20as%20they%20were%20when%20the%20error%20occurred%2C%20but%20all%20changes%20to%20persistent%20database%20state%20within%20the%20block%20are%20rolled%20back.) _exception_ kısmına düşerse otomatik _rollback_ yapıyor.
- [_call stack_](https://www.postgresql.org/docs/15/plpgsql-transactions.html#:~:text=Transaction%20control%20is,SELECT%20in%20between.) durumuna göre _transaction_ yönetebilme imkanın değişiyor: iki `call` arasına `select` girerse son `call` _transaction_'ı bitiremiyor (mu?, bunu da fena uyduruyorum gibime geliyor).
- dolayısıyla burayı iyice anlamadan kolları sıvamamak lazım, benim bunu anlatamayacağım da ayan beyan ortada..
*/

create or replace procedure ornek_trn(bolen int)
language plpgsql
as $$
begin
  update public.actor set first_name = 'ZERO_HERO' where actor_id = 11/abs(sign(bolen));
  --bunu yapamıyorum
  --commit;
  exception
    when division_by_zero or SQLSTATE '22012' then
    null;
    --buna da izin vermiyor
    --rollback;
    update public.actor set first_name = 'ZERO_ONE' where actor_id = 11;
end;
$$;

call ornek_trn(1);
select * from public.actor t where t.actor_id = 11;

call ornek_trn(0);
select * from public.actor t where t.actor_id = 11;

/*markdown
## etrafı temizleyelim:
*/

update public.actor set first_name = 'ZERO' where actor_id = 11;
drop procedure if exists ornek_trn;
--select * from public.actor t where t.actor_id = 11;