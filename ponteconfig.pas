unit ponteconfig;

interface
function aplicaSenha (texto: string): string;

implementation
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

end.
