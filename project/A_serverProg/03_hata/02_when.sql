/*markdown
## madem hatasız kod olmaz
- blok (`begin`/`end;`) içinde `exception when x or y or z` ile başlayıp o hataları bir bir yakalayabilirsin,
- yukarıdaki x,y,z _condition_'ları (hata kodu ya da adıyla) ifade ediyor, bunun dışında bir de `others` var: ben tek siz hepiniz tadında bir kabadayıdır kendisi, her hatayı yakalar.
- birden fazla _condition_ `or` ile bağlanabileceği gibi birden fazla `when` ile de hata yakalama yordamı zenginleştirilebilir.
- hata en yakın bloktan başlayarak dışa doğru ilgili _condition_'ı **ilk** "yakalayan" yordama teslim edilir, kimse hatayı üstüne almazsa ihale _client_'a verilir.
- [_exception_](https://www.postgresql.org/docs/15/plpgsql-control-structures.html#:~:text=A%20block%20containing%20an%20EXCEPTION%20clause%20is%20significantly%20more%20expensive%20to%20enter%20and%20exit%20than%20a%20block%20without%20one.%20Therefore%2C%20don%27t%20use%20EXCEPTION%20without%20need.) pahalı bi'şey, programın akışını yönetmek üzere değil gerçekten "olağan dışı" durumlar için kullanılmalı.
*/

do $$
begin
  raise division_by_zero;
  exception
    --en yakın bloktaki ilk uygun condition hatayı yakalar:
    when others then
      -- ve boşver derse
      null;
    when division_by_zero or SQLSTATE '22012' then
      --sıfıra bölme hakkında yazdığınız o güzel hata mesajı güme gider!
      raise 'neden hala birileri sıfıra bölmenin şakasını yapıyor?';
end;
$$;

/*markdown
### bir de matruşka örneği yapalım, neşemizi bulalım
*/

do $$
begin
  begin
    begin
      begin
        begin
          raise division_by_zero;
          exception when others then raise 'bu tutmuş';
        end;
        exception when others then raise 'bu kesmiş';
      end;
      exception when others then raise 'bu pişirmiş';
    end;
    exception when others then raise 'bu yemiş';
  end;
  exception when others then raise 'bu da hani banaaa demiş';
end;
$$;

/*markdown
### demek ki en iyi temizlik kirletmemekmiş! öyleyse en iyi hata da hiç fırlatılmayandır; yoksa hiç yakalanmayan mıdır?
*/