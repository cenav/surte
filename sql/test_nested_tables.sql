declare
  type t_detail is record (
    text varchar2(30),
    num  number(3)
  );

  type t_details is table of t_detail;

  type t_header is record (
    text    varchar2(30),
    num     number(3),
    details t_details
  );

  type t_headers is table of t_header;

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
    p_header.details := t_details();
    for i in 1 .. 5 loop
      p_header.details.extend;
      detail(p_header.details(p_header.details.last));
    end loop;
  end;

  procedure main is
    l_headers t_headers := t_headers();
  begin
    for i in 1 .. 3 loop
      l_headers.extend;
      header(l_headers(l_headers.last));
    end loop;

    for i in 1 .. l_headers.count loop
      dbms_output.put_line('header text: ' || ' ' || l_headers(i).text);
      dbms_output.put_line('header number: ' || ' ' || l_headers(i).num);
      for j in 1 .. l_headers(i).details.count loop
        dbms_output.put_line('detail text: ' || ' ' || l_headers(i).details(j).text);
        dbms_output.put_line('detail number: ' || ' ' || l_headers(i).details(j).num);
      end loop;
    end loop;
  end;

begin
  main();
end;
