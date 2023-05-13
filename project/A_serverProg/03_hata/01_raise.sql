/*markdown
## hatasız kod olmaz
- `raise` ile farklı dozlarda durumdan şikâyet edebilirsin:
  - _debug_
  - _log_
  - _info_
  - _notice_
  - _warning_
  - **exception** ki kendisi _default_ olur
- `exception` (eğer birisi hatayı "yakalayıp" akışı değiştirmediyse) kapı pencere indirerek _transaction_'ı harap etmeden sakinleşmez.
- diğerlerinin hepsi sadece futbol yorumcusu gibi şöyle olmuş böööle olmuş diye tarihe not düşerler.
- ortamdaki [ayar](https://www.postgresql.org/docs/current/runtime-config-logging.html#GUC-LOG-MIN-MESSAGES) durumuna göre PG (ya da ilgili [_client_](https://www.postgresql.org/docs/current/runtime-config-client.html#GUC-CLIENT-MIN-MESSAGES)) bu yorumcuları dinler ya da dinlemez.
- [_PSQL_](https://www.postgresql.org/docs/current/app-psql.html) gibi bu evin bireyi olan bir _client_ kullanıyorsan `exception` dışı mesajlar faydalı olabilir ama diğer DBMS'lerle de iletişim kurmak üzere tasarlanmış bi'şey ile bağlanıyorsan bu mesajları <u>duy**ma**ma</u> ihtimalin yüksek (ki biz _SQL Notebook_ ile bağlanıyoruz ve bu alet `exception` dışını algılayamıyor). dolayısıyla "olağan dışı" bir durum varsa bunu karşı tarafa `exception` olarak ilet.
- _level_ ardından [kullanabileceğin](https://www.postgresql.org/docs/current/plpgsql-errors-and-messages.html) bir sürü şekil mevcut.
- [hata kodlarına](https://www.postgresql.org/docs/current/errcodes-appendix.html) ve bunların _condition_ adlarına da girmiyoruz ama bunlar önemli.
- sadece blok (`begin`/`end;`) içinde hata yakalama kısmında (`exception when ...`)  `raise;` şeklinde kullanıp "yakalanan" hatayı tekrar "fırlatabilirsin", artık kimin kucağına düşerse..
*/

do $$
begin
  raise debug 'DUY BENİİ %', 1;
  raise log 'DUY BENİİ %', 2;
  raise info 'DUY BENİİ %', 3;
  raise notice 'DUY BENİİ %', 4;
  raise warning 'DUY BENİİ %', 5;
  --buraya kadar olan muhabbetten hiç haberimiz olmayacak ama bunu kaçırma şansımız yok:
  raise exception 'DUY BENİİ %', 6;
end;
$$;

do $$
begin
  --level yoksa exception var; buradaki division_by_zero hatanın "lakabı"
  raise division_by_zero;
end;
$$;

do $$
begin
  --"hata kodunu da ezbere bilirim" böbürüyle de raise edebilirsin:
  raise sqlstate '2201E';
end;
$$;

/*markdown
### oley, temizleyecek bi'şey yok bu sefer!
*/