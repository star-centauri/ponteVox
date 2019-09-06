unit ponteProcessa;

interface
uses
    dvcrt,
    dvwin,
    dvform,
    sysutils,
    classes,
    pontemsg,
    pontevars,
    ponteconfig;

procedure processa;

implementation

{--------------------------------------------------------}
{ Gera um form padr�o a parti de uma ponte(nova ou n�o)  }
{--------------------------------------------------------}
procedure criarFormPonte(out ponte: UserPonte);
const
    tipoponte :  string = 'WEB|FTP|DROPBOX';
begin
    formCria;

    formCampo      ('PTNOME',     'Nome',                                            ponte.Nome,     50);
    formCampolista ('PTTIPO',     'Tipo (F9 Ajuda)',                                 ponte.Tipo,     10, tipoponte);
    formcampo      ('PTSERVIDOR', 'Servidor',                                        ponte.Servidor, 50);
    formcampoint   ('PTPORTA',    'Porta',                                           ponte.Porta);
    formCampoBool  ('',           'Autentica��o autom�tica? (somente para DROPBOX)', ponte.Auth);
    formcampo      ('PTCONTA',    'Conta',                                           ponte.Conta,    20);
    formcampo      ('PTSENHA',    'Senha',                                           ponte.Senha,    15);
    formEdita(true);
end;

{--------------------------------------------------------}
{        Gravar os dados da ponte no pontes.ini          }
{--------------------------------------------------------}
procedure gravarPonteSintAmbiente(ponte: UserPonte);
var
    senha: string;
begin
    senha := aplicaSenha(ponte.Senha);
    {inserindo no arquivo ini}
    sintGravaAmbienteArq(ponte.Nome, 'Nome',     ponte.Nome,            arqIniPontes);
    sintGravaAmbienteArq(ponte.Nome, 'Tipo',     ponte.Tipo,            arqIniPontes);
    sintGravaAmbienteArq(ponte.Nome, 'Servidor', ponte.Servidor,        arqIniPontes);
    sintGravaAmbienteArq(ponte.Nome, 'Porta',    intTostr(ponte.Porta), arqIniPontes);
    sintGravaAmbienteArq(ponte.Nome, 'Conta',    ponte.Conta,           arqIniPontes);
    sintGravaAmbienteArq(ponte.Nome, 'Senha',    senha,                 arqIniPontes);
    sintGravaAmbienteArq(ponte.Nome, 'Auth',     BoolToStr(ponte.Auth), arqIniPontes);
end;

{--------------------------------------------------------}
{              Retornar ponte do pontes.ini              }
{--------------------------------------------------------}
procedure getPonteSintAmbiente(ponteNome: string; out ponte: UserPonte);
begin
    ponte.Nome     := sintambientearq(ponteNome,           'Nome',     'N�o registrado', arqIniPontes);
    ponte.Tipo     := sintambientearq(ponteNome,           'Tipo',     'N�o registrado', arqIniPontes);
    ponte.Servidor := sintambientearq(ponteNome,           'Servidor', 'N�o registrado', arqIniPontes);
    ponte.Porta    := strtoint(sintambientearq(ponteNome,  'Porta',    'N�o registrado', arqIniPontes));
    ponte.Conta    := sintambientearq(ponteNome,           'Conta',    'N�o registrado', arqIniPontes);
    ponte.Senha    := sintambientearq(ponteNome,           'Senha',    'N�o registrado', arqIniPontes);
    ponte.Auth     := StrToBool(sintambientearq(ponteNome, 'Auth',     'N�o registrado', arqIniPontes));
end;

{--------------------------------------------------------}
{                     editar ponte                       }
{--------------------------------------------------------}
procedure editar(ponteNome: string);
var
    ponte: UserPonte;

begin
    clrscr;
    textBackground (BLUE);
    Writeln ('Editar Ponte: ');
    writeln;
    textBackground (BLACK);

    getPonteSintAmbiente(ponteNome, ponte);
    ponte.Senha := aplicaSenha(ponte.Senha);

    criarFormPonte(ponte);

    if ponte.Nome <> '' then
        begin
            ponte.Senha := aplicaSenha(ponte.Senha);

            {inserindo no arquivo ini}
            gravarPonteSintAmbiente(ponte);

            {fim da inser��o}
            mensagem ('PTPONTE', 0); // a ponte
            sintwrite(ponte.Nome);
            mensagem('PTPONTEI', 0); // foi inserida com sucesso
        end
    else
        begin
            textBackground (MAGENTA);
            writeln;
            mensagem ('PTBRANCO', 1);  //'Nome em branco.  Registro ignorado'
            textBackground (BLACK);
            exit;
        end;
end;


{--------------------------------------------------------}
{                         listar ponte                   }
{--------------------------------------------------------}
procedure listar(ponteNome: string);
var
    ponte: UserPonte;

begin
    clrscr;
    textBackground (BLUE);
    Writeln ('Listar Ponte: ');
    writeln;
    textBackground (BLACK);

    if ponteNome = '' then
        begin
            sintWrite('Nome d� ponte n�o est� definida.');
            exit;
        end;

    getPonteSintAmbiente(ponteNome, ponte);

    if ponte.Nome <> 'N�o registrado' then
    begin
        {imprimindo valores recebidos}
        textBackground (BLACK);

        ponte.Senha := aplicaSenha(ponte.Senha);
        {formulario de exibicao de  ponte}
        formCria;
        formCampo    ('', 'Nome',            ponte.Nome,50);
        formCampo    ('', 'Tipo',            ponte.Tipo,3);
        formCampo    ('', 'Servidor',        ponte.Servidor, 50);
        formCampoint ('', 'Porta',           ponte.Porta);
        formCampo    ('', 'Conta',           ponte.Conta,20);
        formcampo    ('', 'Senha',           ponte.Senha,15);
        formCampoBool('', 'Auth autom�tico', ponte.Auth);
        formEdita(false);

    end;

    if ponte.Nome = 'N�o registrado' then
        mensagem ('PTNREGIST', 1); { ponte n�o registrada }

    clrscr;
end;

{--------------------------------------------------------}
{                       remover ponte                    }
{--------------------------------------------------------}
procedure remover(ponteNome: string);
begin
    clrscr;
    textBackground (BLUE);
    Writeln ('Remover Ponte: ');
    writeln;
    textBackground (BLACK);

    if ponteNome = '' then
        begin
            sintWrite('Nome d� ponte n�o est� definida.');
            exit;
        end;

    sintremoveambientearq(ponteNome, '', arqIniPontes);
    mensagem ('PTSUCESSO', 0); { ponte removida com sucesso }
    clrscr;
end;

{--------------------------------------------------------}
{         executar comando da ponte selecionada          }
{--------------------------------------------------------}
procedure executarComandoSelecionado(option: char; ponteNome: string);
begin
    limpaBaixo (wherey);

    case upcase(option) of
        'L': listar(ponteNome);   { procedure de listagem de pontes    }
        'R': remover(ponteNome);  { procedure de remo��o de pontes    }
        'E': editar(ponteNome);   { procedure de edi��o de ponte}
    else
        textBackground (MAGENTA);
        mensagem ('PTOPCAOI', 0); //op��o inv�lida
        textBackground (BLACK);
        clrscr;
    end;
end;

{--------------------------------------------------------}
{           executar comando da ponte existente          }
{--------------------------------------------------------}
function selecionarOpcaoPonte: char;
var
    n: integer;
const
    tabLetrasOpcao: string = 'LRE' + ESC;
begin
    sintWrite('O que deseja fazer com a Ponte?');

    popupMenuCria (wherex, wherey, 50, length(tabLetrasOpcao), MAGENTA);
    popupMenuAdiciona ('',  'L - Listar Ponte');
    popupMenuAdiciona ('',  'R - Remover Ponte');
    popupMenuAdiciona ('',  'E - Editar Ponte');

    popupMenuAdiciona ('PTTERMINAR', 'ESC - terminar' );

    n := popupMenuSeleciona;
    if n > 0 then
        begin
            Result := tabLetrasOpcao[n];
            writeln(tabLetrasOpcao[n]);
        end
    else
        Result := ESC;
end;

{--------------------------------------------------------}
{                      folhear pontes                    }
{--------------------------------------------------------}
procedure folhear();
var sl: TStringList;
    i, n: integer;
    opcao: char;
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
        opcao := selecionarOpcaoPonte;
        executarComandoSelecionado(opcao, sl[n-1]);
    end;

end;

{--------------------------------------------------------}
{           Verificar se ponte j� foi criada             }
{--------------------------------------------------------}
function verificarPonteExiste(ponteNome: string) : boolean;
var
    existeNome: string;
begin
    Result := false;
    existeNome := sintambientearq(ponteNome, 'Nome', '', arqIniPontes);

    if existeNome <> '' then
        begin
            sintWriteLn('A ponte ' + existeNome + ' j� foi criada.');
            sintWriteLn('Deseja sobrescever a anterior?');
            
            if popupMenuPorLetra('SN') = 'N' then
                begin
                    sintWriteLn('Infome um novo nome, ou deixe o nome em branco e aperte ESC para excluir.');
                    Result := true;
                end;
        end
end;

{--------------------------------------------------------}
{                     Inserir Pontes                     }
{--------------------------------------------------------}
procedure inserir;
var
    novaPonte: UserPonte;
    validaSeExiste: boolean;

begin
    clrscr;
    Writeln ('Adicionar Ponte: ');
    writeln;
    textBackground (BLACK);
    TextColor(White);

    validaSeExiste := true;
    novaPonte.Nome := '';
    {formulario de inser��o de pontes}
    Repeat
        clrscr;
        criarFormPonte(novaPonte);

        if novaPonte.Nome = '' then
            begin
                textBackground (BLUE);
                mensagem('PTBRANCO', 0); { nome em branco registro ignorado }
                textBackground (BLACK);
                exit;
            end
        else
            validaSeExiste := verificarPonteExiste(novaPonte.Nome);
    Until not validaSeExiste;

    gravarPonteSintAmbiente(novaPonte);
    mensagem ('PTPONTE', 0); // a ponte
    sintwrite(novaPonte.Nome);
    mensagem('PTPONTEI', 0); // foi inserida com sucesso
    clrscr;
end;

{--------------------------------------------------------}
{           executar comando que foi solicitado          }
{--------------------------------------------------------}
procedure executarComando(option: char);
begin
    limpaBaixo (wherey);

    case upcase(option) of
        'I': inserir;  { procedure de inser��o de pontes    }
        'F': folhear;  { procedure de folheamento de pontes  }
    else
        textBackground (MAGENTA);
        mensagem ('PTOPCAOI', 0); //op��o inv�lida
        textBackground (BLACK);
        clrscr;
    end;
end;

{--------------------------------------------------------}
{            seleciona a op��o com as setas              }
{--------------------------------------------------------}
function selSetasOpcao: char;
var
    n: integer;
const
    tabLetrasOpcao: string = 'IF' + ESC;

begin
    garanteEspacoTela (9);
    popupMenuCria (wherex, wherey, 50, length(tabLetrasOpcao), MAGENTA);
    popupMenuAdiciona ('PTINSERIR',  'I - Inserir Ponte');
    popupMenuAdiciona ('PTLISTAR',   'L - Listar Ponte');

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
{            seleciona a teclas de a��es                 }
{--------------------------------------------------------}
procedure selecionarOpcoes(out processa: boolean);
var keypress1, keypress2: char;
    opcao: string;

begin
    opcao := '';
    sintLeTecla (keypress1, keypress2);

    if (keypress1 = #0) and ((keypress2 = CIMA) or (keypress2 = BAIX) or (keypress2 = F9)) then
        begin
            keypress1 := selSetasOpcao;
            if keypress1 <> #$1b then
                opcao := copy(opcoesItemSelecionado, pos('-', opcoesItemSelecionado)-1, 999);
        end;

    if keypress1 = ESC then
        begin
            processa := false;
            exit;
        end;

    executarComando(keypress1);
end;

{--------------------------------------------------------}
{                loop de processamento                   }
{--------------------------------------------------------}
procedure processa;
var processa: boolean;
begin
    processa := true;

    while processa do
        begin
            textBackground (BLUE);
            mensagem ('PTOPCAO', 0);   { Qual sua op��o? }
            textBackground (BLACK);

            selecionarOpcoes(processa);
        end;
end;

end.
