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

  function make_detail(
    p_text varchar2
  , p_num  number
  ) return t_detail is
    l_detail t_detail;
  begin
    l_detail.text := p_text;
    l_detail.num := p_num;
    return l_detail;
  end;

  procedure add_detail(
    p_details in out t_details
  , p_detail         t_detail
  ) is
    l_idx pls_integer;
  begin
    p_details.extend;
    l_idx := p_details.last;
    p_details(l_idx) := p_detail;
  end;

  function make_header(
    p_text varchar2
  , p_num  number
  ) return t_header is
    l_header t_header;
  begin
    l_header.text := p_text;
    l_header.num := p_num;
    l_header.details := t_details();
    return l_header;
  end;

  procedure add_header(
    p_headers in out t_headers
  , p_header         t_header
  ) is
    l_idx pls_integer;
  begin
    p_headers.extend;
    l_idx := p_headers.last;
    p_headers(l_idx) := p_header;
  end;

  procedure main is
    l_headers t_headers := t_headers();
  begin
    for i in 1 .. 3 loop
      add_header(l_headers, make_header('header ' || i, i));
      for j in 1 .. 5 loop
        add_detail(l_headers(i).details, make_detail('detail ' || j, j));
      end loop;
    end loop;
    print(l_headers);
  end;

begin
  main();
end;