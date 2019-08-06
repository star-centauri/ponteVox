{--------------------------------------------------------}
{                                                        }
{    Programa: PonteVox                                  }
{                                                        }
{    Módulo de Controle das pontes do Dosvox             }
{                                                        }
{    Autores: João Marcelo & João Pedro                  }
{                                                        }
{    Em julho/2018                                       }
{                                                        }
{--------------------------------------------------------}

program pontevox;

uses

  windows,
  dvcrt,
  dvwin,
  dvform,
  sysutils,
  classes,
  pontemsg;


const

  versao = '2.0';

var
  arqIniPontes: string;


{--------------------------------------------------------}
{                  Criptografar senha                    }
{--------------------------------------------------------}

function aplicaSenha (texto: string): string;
var i: integer;
    senha: string;
    modelo: string;
    x, y: integer;
begin
    modelo := '';
    x := length(texto);
    y := 54;
    for i := 1 to 80 do
        begin
             x := (x + y + i) mod 16;
             y := x;
             modelo := modelo + chr(x);
        end;

    for i := 1 to length(texto) do
        texto[i] := chr(ord(texto[i]) xor ord(modelo[i]));

    result := texto;
end;

{--------------------------------------------------------}
{                        Validação                       }
{--------------------------------------------------------}

function validacao (nome: shortstring): boolean;
var
    spontes: TstringList;
    i : integer;
    aux : boolean;

begin
    spontes := sintItensAmbienteArq ('', arqIniPontes);

    {Percorrendo a StringList}

    aux := false;
    for i := 0 to spontes.count-1 do
    begin
        if nome = spontes[i] then
        begin
            aux := true;
            break;
        end
        else
            aux := false;
    end;

    result := aux;
    spontes.free;
end;

{--------------------------------------------------------}
{                     editar ponte                       }
{--------------------------------------------------------}

procedure editar(nomeDig: shortstring);
var
    snome: string;
    tipo, servidor, conta, senha, nome : shortstring;
    porta : integer;

begin
    clrscr;
    textBackground (BLUE);
    Writeln ('Editar Ponte: ');
    writeln;
    textBackground (BLACK);

    if nomeDig = '' then
        begin
            mensagem ('PTDIGITEL', 0); // digite a ponte a listar
            sintreadln(snome);

            if snome = '' then
                exit;
        end
    else
        snome := nomeDig;

    writeln;
    {recebendo valores}
    nome := sintambientearq(snome, 'Nome', 'Não registrado', arqIniPontes);
    tipo := sintambientearq(snome, 'Tipo', 'Não registrado', arqIniPontes);
    servidor := sintambientearq(snome, 'Servidor', 'Não registrado', arqIniPontes);
    porta := strtoint(sintambientearq(snome, 'Porta', 'Não registrado', arqIniPontes));
    conta := sintambientearq(snome, 'Conta', 'Não registrado', arqIniPontes);
    senha := sintambientearq(snome, 'Senha', 'Não registrado', arqIniPontes);
    {valores recebidos}
    senha := aplicaSenha(senha);

    {imprimindo valores recebidos}
    clrscr;
    textBackground (BLUE);
    Writeln ('Listar Ponte: ');
    writeln;

    {formulario de exibicao de  ponte}

    formCria;
    formCampo('', 'Nome', nome, 50);
    formcampo('', 'Tipo', tipo, 20);
    formcampo('', 'Servidor', servidor, 50);
    formcampoint('', 'Porta', porta);
    formcampo('', 'Conta', conta, 100);
    formcampo('', 'Senha', senha, 15);
    formEdita(true);

    {fim do formulario}

    if nome<>'' then
    begin
        senha := aplicaSenha(senha);

        {inserindo no arquivo ini}
        sintGravaAmbienteArq(nome,'Nome', nome, arqIniPontes);
        sintGravaAmbienteArq(nome, 'Tipo', UpperCase(tipo), arqIniPontes);
        sintGravaAmbienteArq(nome, 'Servidor', servidor, arqIniPontes);
        sintGravaAmbienteArq(nome, 'Porta', intTostr(porta), arqIniPontes);
        sintGravaAmbienteArq(nome, 'Conta', conta, arqIniPontes);
        sintGravaAmbienteArq(nome, 'Senha', senha, arqIniPontes);

        {fim da inserção}
        writeln;
        mensagem ('PTPONTE', 0); // a ponte
        sintwrite(nome);
        mensagem('PTPONTEI', 0); // foi inserida com sucesso
    end
    else
    begin
        textBackground (MAGENTA);
        writeln;
        mensagem ('PTBRANCO', 1);  //'Nome em branco.  Registro ignorado'
        textBackground (BLACK);
        delay (2000);
        exit;
    end;

end;

{--------------------------------------------------------}
{                        Cabeçalho                       }
{--------------------------------------------------------}

procedure cabecalho;
begin
    clrscr;
    textBackground (BLUE);
    writeln ('PonteVox');
    textBackground (BLACK);
    writeln;

end;

{--------------------------------------------------------}
{                    Inicializa                          }
{--------------------------------------------------------}

procedure inicializa;
var ambiente: string;
begin
    clrscr;
    setWindowTitle('PONTEVOX');  { nome do programa }

    ambiente := sintAmbiente('PONTEVOX', 'DIRPONTEVOX');
    if ambiente = '' then
        ambiente := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\PonteVox';

    arqIniPontes := sintAmbiente('PONTEVOX', 'ARQPONTES');
    if arqIniPontes = '' then
        arqIniPontes := sintDirAmbiente + '\pontes.ini';
    if not fileExists (arqIniPontes) then
        arqIniPontes := '.\pontes.ini';

    sintinic (0, ambiente);

    textBackground (BLUE);
    mensagem ('PTINIC', 0);
    sintWriteln (versao);
    writeln;
    textBackground (BLACK);
end;

{--------------------------------------------------------}
{                        ajuda
{--------------------------------------------------------}

procedure ajudaOpcao;
begin

    writeln;

    mensagem ('PTOPCAO', 1);    { qual sua opção?  }
    mensagem ('PTINSERIR', 1);  { I - inserir      }
    mensagem ('PTLISTAR', 1);   { L - listar       }
    mensagem ('PTREMOVER', 1);  { R -  remover     }
    mensagem ('PTFOLHEAR', 1);  { F - folhear      }
    mensagem ('PTTERMINAR', 1); { ESC - termina    }

    while keypressed do readkey;
    gotoxy (1, 3);
    limpaBaixo (wherey);
    sintBip;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas              }
{--------------------------------------------------------}

function selSetasOpcao: char;

var n: integer;
const
    tabLetrasOpcao: string = 'ILRFE' + ESC;

begin
    garanteEspacoTela (9);
    popupMenuCria (wherex, wherey, 50, length(tabLetrasOpcao), MAGENTA);
    popupMenuAdiciona ('PTINSERIR',  'I - Inserir Ponte');
    popupMenuAdiciona ('PTLISTAR',   'L - Listar Ponte');
    popupMenuAdiciona ('PTREMOVER',  'R - Remover Ponte');
    popupMenuAdiciona ('PTFOLHEAR',  'F - Folhear Ponte');
    popupMenuAdiciona ('',           'E - Editar Ponte');
    popupMenuAdiciona ('PTTERMINAR', 'ESC - terminar' );

    n := popupMenuSeleciona;
    if n > 0 then
        begin
            selSetasOpcao := tabLetrasOpcao[n];
            writeln (tabLetrasOpcao[n]);
        end
    else
        selSetasOpcao := ESC;
end;

{--------------------------------------------------------}
{                     Inserir Pontes                     }
{--------------------------------------------------------}

procedure inserir;
var
    nome, tipo, servidor, conta, senha : shortstring;
    porta : integer;
    valida : boolean;

const
    tipoponte :  string = 'WEB|FTP|P2P|DROPBOX';
begin
    clrscr;
    textBackground (BLUE);
    Writeln ('Adicionar Ponte: ');
    writeln;
    textBackground (BLACK);

    nome :='';
    tipo := '';
    servidor := '';
    conta := '';
    senha := '';

    {formulario de inserção de pontes}

    formCria;

    formCampo ('PTNOME',      'Nome', nome,50);
    formCampolista ('PTTIPO', 'Tipo (F9 Ajuda)',tipo, 10, tipoponte);
    formcampo ('PTSERVIDOR',  'Servidor', servidor, 50);
    formcampoint ('PTPORTA',  'Porta', porta);
    formcampo ('PTCONTA',     'Conta', conta, 20);
    formcampo ('PTSENHA',     'Senha', senha, 15);
    formEdita (true);

    {fim do formulario}

    if nome = '' then
        begin
            textBackground (BLUE);
            mensagem('PTBRANCO', 0); // nome em branco registro ignorado
            textBackground (BLACK);
            delay (2000);
            exit;
        end;

    {Validação de Pontes}

    valida := validacao(nome);

    if valida = true then
    begin
          editar(nome); // solicitando a procedure de edição
    end
    {fim da validação de pontes}
    else
    begin
        senha := aplicaSenha(senha);
        {inserindo no arquivo ini}
        sintGravaAmbienteArq(nome, 'Nome', nome, arqIniPontes);
        sintGravaAmbienteArq(nome, 'Tipo', tipo, arqIniPontes);
        sintGravaAmbienteArq(nome, 'Servidor', servidor, arqIniPontes);
        sintGravaAmbienteArq(nome, 'Porta', intTostr(porta), arqIniPontes);
        sintGravaAmbienteArq(nome, 'Conta', conta, arqIniPontes);
        sintGravaAmbienteArq(nome, 'Senha', senha, arqIniPontes);

        {fim da inserção}

        clrscr;
        textBackground (BLUE);
        Writeln ('Adicionar Ponte: ');
        textBackground (BLACK);

        writeln;
        mensagem ('PTPONTE', 0); // a ponte
        sintwrite(nome);
        mensagem('PTPONTEI', 0); // foi inserida com sucesso
        delay(2000);
        clrscr;
    end;
end;

{--------------------------------------------------------}
{                         listar ponte                   }
{--------------------------------------------------------}

procedure listar;
var
    snome: string;
    nome, tipo, servidor, conta, senha : shortstring;
    porta : integer;

begin
    clrscr;
    textBackground (BLUE);
    Writeln ('Listar Ponte: ');
    writeln;
    textBackground (BLACK);

    mensagem ('PTDIGITEL', 0); // digite a ponte a listar
    sintreadln(snome);

    if snome = '' then
        exit;

    writeln;
    {recebendo valores}

    nome := sintambientearq(snome, 'Nome', 'Não registrado', arqIniPontes);
    tipo := sintambientearq(snome, 'Tipo', 'Não registrado', arqIniPontes);
    servidor := sintambientearq(snome, 'Servidor', 'Não registrado', arqIniPontes);
    porta := strtoint(sintambientearq(snome, 'Porta', 'Não registrado', arqIniPontes));
    conta := sintambientearq(snome, 'Conta', 'Não registrado', arqIniPontes);
    senha := sintambientearq(snome, 'Senha', 'Não registrado', arqIniPontes);
    {valores recebidos}

    if nome <> 'Não registrado' then
    begin
        {imprimindo valores recebidos}
        clrscr;
        textBackground (BLUE);
        Writeln ('Listar Ponte: ');
        writeln;
        textBackground (BLACK);

        senha := aplicaSenha(senha);

        {formulario de exibicao de  ponte}
        formCria;
        formCampo('', 'Nome', nome,50);
        formCampo('', 'Tipo', tipo,3);
        formCampo('', 'Servidor', servidor, 50);
        formCampoint('', 'Porta', porta);
        formCampo('', 'Conta', conta,20);
        formcampo('', 'Senha', senha,15);
        formEdita(false);

        {fim do formulario}

    end;

    if nome = 'Não registrado' then
    begin
        clrscr;
        mensagem ('PTNREGIST', 1); // ponte não registrada
        delay(2000)
    end;

    clrscr;
end;

{--------------------------------------------------------}
{                       remover ponte                    }
{--------------------------------------------------------}

procedure remover;
var
    nome : string;

begin
    clrscr;
    textBackground (BLUE);
    Writeln ('Remover Ponte: ');
    writeln;
    textBackground (BLACK);

    mensagem ('PTDIGITE', 0); //digite o nome da ponte a ser removida
    sintreadln(nome);

    if nome = '' then exit;

    sintremoveambientearq(nome, '', arqIniPontes);

    clrscr;
    textBackground (BLUE);
    Writeln ('Remover Ponte: ');
    writeln;
    textBackground (BLACK);
    mensagem ('PTSUCESSO', 0); //ponte removida com sucesso
    delay(2000);
    clrscr;
end;

{--------------------------------------------------------}
{                     mostra uma Ponte                   }
{--------------------------------------------------------}

function mostraumaPonte (n: integer; sl: TStringList): char;
var
    nome, tipo, servidor, conta, senha : shortstring;
    porta : integer;
    snome : string;

begin
    if n < 1 then
        begin
           sintBip;
           result := #81;
           exit;
        end;

    if n > sl.count then
        begin
           sintBip;
           result := #73;
           exit;
        end;

    snome:=sl[n-1];

    nome := sintambientearq(snome, 'Nome', 'Não registrado', arqIniPontes);
    tipo := sintambientearq(snome, 'Tipo', 'Não registrado', arqIniPontes);
    servidor := sintambientearq(snome, 'Servidor', 'Não registrado', arqIniPontes);
    porta := strtoint(sintambientearq(snome, 'Porta', 'Não registrado', arqIniPontes));
    conta := sintambientearq(snome, 'Conta', 'Não registrado', arqIniPontes);
    senha := sintambientearq(snome, 'Senha', 'Não registrado', arqIniPontes);

    {valores recebidos}
    if nome <> 'Não registrado' then
    begin
         {imprimindo valores recebidos}
         clrscr;
         textBackground (BLUE);
         Writeln ('Listar Ponte: ');
         writeln;
         textBackground (BLACK);

         senha := aplicaSenha(senha);

         {formulario de exibicao de ponte}
         formCria;
         formCampo('', 'Nome', nome,50);
         formcampo('', 'Tipo', tipo,3);
         formcampo('', 'Servidor', servidor, 50);
         formcampoint('', 'Porta', porta);
         formcampo('', 'Conta', conta,20);
         formcampo('', 'Senha', senha,15);

         mostraumaPonte := formEdita(false);   // o retorno é um caractere que termina o formulário

        {fim do formulario}

    end
    else
        begin
            mensagem ('PTNREG', 0); // não registrado
            delay(2000);
            result := esc;
        end;
end;

{--------------------------------------------------------}
{                      folhear ponte                     }
{--------------------------------------------------------}

procedure folhear;
var sl : TStringList;
    i, n: integer;
    c: char;
    s: string;

begin
    clrscr;
    textBackground (BLUE);
    Writeln ('Folhear Pontes: ');
    writeln;
    textBackground (BLACK);

    sl := sintItensAmbienteArq ('', arqIniPontes);

    mensagem('PTENCONTRADOS', 0); //foram encontrados
    sintwrite(intToStr (sl.count));
    mensagem('PTREG', 2); // registros

    popupMenuCria (wherex, wherey, 20, sl.count, blue);
    for i := 0 to sl.count-1 do
        begin
            s := sintAmbienteArq (sl[i], 'Nome', '', arqIniPontes);
            popupmenuadiciona('', s);
        end;

    n := popupMenuSeleciona;


    if n > 0 then
    begin
      repeat
        c := mostraumaPonte(n, sl);
        if c = #73 then
            n := n - 1
        else
        if c = #81 then
            n := n + 1;
      until c = #27;

    end;
    sl.free;

end;

{--------------------------------------------------------}
{                loop de processamento                   }
{--------------------------------------------------------}

procedure processa;
var c, c2: char;
    opcao: string;
label fim;

begin
    while true do
        begin
            opcao := '';

            cabecalho;
            textBackground (BLUE);
            mensagem ('PTOPCAO', 0);   { Qual sua opção? }
            textBackground (BLACK);

            sintLeTecla (c, c2);
            if (c = #0) and ((c2 = CIMA) or (c2 = BAIX) or (c2 = F9)) then
                  begin
                      c := selSetasOpcao;
                      if c <> #$1b then
                          opcao := copy ( opcoesItemSelecionado, pos ('-', opcoesItemSelecionado)-1, 999);
                  end;

            if c = ESC then
                begin
                    writeln;
                    goto fim;
                end;

            if (c = #0) and (c2 = F1) then
                 ajudaOpcao
            else
                 begin
                     limpaBaixo (wherey);

                     case upcase(c) of
                         'I': inserir;  { procedure de inserção de pontes    }
                         'L': listar;   { procedure de listagem de pontes    }
                         'R': remover;  { procedure de remoção de pontes    }
                         'F': folhear;  { procedure de folheamento de pontes  }
                         'E': editar('');   { procedure de edição de ponte}

                    else
                         textBackground (MAGENTA);
                         mensagem ('PTOPCAOI', 0); //opção inválida
                         textBackground (BLACK);
                         delay(1500);
                         clrscr;
                     end;
                 end;
        end;
fim:
    writeln;
end;

{--------------------------------------------------------}
{                     fecha o programa                   }
{--------------------------------------------------------}

procedure termina;
begin
    mensagem ('PTFIM', 0); // fim do programa
    sintfim;
    doneWinCrt;
end;

{--------------------------------------------------------}
{                   programa principal                   }
{--------------------------------------------------------}

begin
    inicializa;
    processa;
    termina;
end.
