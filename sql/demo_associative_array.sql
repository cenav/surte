-- test pass by reference
declare
  type t_detail is record (
    text varchar2(30),
    num  number(3)
  );

  type t_details is table of t_detail index by pls_integer;

  type t_header is record (
    text    varchar2(30),
    num     number(3),
    details t_details
  );

  type t_headers is table of t_header index by pls_integer;

  procedure init(
    p_headers in out t_headers
  ) is
  begin
    for i in 1 .. 3 loop
      p_headers(i).text := 'header';
      p_headers(i).num := 1;
      for j in 1 .. 3 loop
        p_headers(i).details(j).text := 'detail';
        p_headers(i).details(j).num := 2;
      end loop;
    end loop;
  end;

  procedure print(
    p_headers t_headers
  ) is
  begin
    for i in 1 .. p_headers.count loop
      dbms_output.put_line('header text: ' || ' ' || p_headers(i).text);
      dbms_output.put_line('header number: ' || ' ' || p_headers(i).num);
      for j in 1 .. p_headers(i).details.count loop
        dbms_output.put_line('detail text: ' || ' ' || p_headers(i).details(j).text);
        dbms_output.put_line('detail number: ' || ' ' || p_headers(i).details(j).num);
      end loop;
    end loop;
  end;

  procedure detail(
    p_detail in out t_detail
  ) is
  begin
    p_detail.text := 'inner';
    p_detail.num := 2;
  end;

  procedure header(
    p_header in out t_header
  ) is
  begin
    p_header.text := 'outer';
    p_header.num := 1;
    for i in 1 .. p_header.details.count loop
      detail(p_header.details(i));
    end loop;
  end;

  procedure main is
    l_headers t_headers;
  begin
    init(l_headers);
    for i in 1 .. l_headers.count loop
      header(l_headers(i));
    end loop;
  end;
begin
  main();
end;