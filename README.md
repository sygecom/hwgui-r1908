# hwgui-r1908
HWGUI r1908 para testes com Harbour e xHarbour 32-bit/64-bit

# Compatibilidade

| Projeto   | Compilador C/C++ | Status   | Status (HWG_USE_POINTER_ITEM) | Notas |
| --------- | ---------------- | -------- | ----------------------------- | ----- |
| Harbour   | MinGW32          | estável  | ? | ...   |
| Harbour   | MinGW64          | estável  | ? | ...   |
| Harbour   | MSVC32           | estável  | ? | ...   |
| Harbour   | MSVC64           | estável  | ? | ...   |
| Harbour   | Clang32          | ?        | ? | ...   |
| Harbour   | Clang64          | ?        | ? | ...   |
| xHarbour  | MinGW32          | ?        | ? | ...   |
| xHarbour  | MinGW64          | ?        | ? | ...   |
| xHarbour  | MSVC32           | ?        | ? | ...   |
| xHarbour  | MSVC64           | ?        | ? | ...   |
| xHarbour  | Clang32          | ?        | ? | ...   |
| xHarbour  | Clang64          | estável  | ? | ...   |
| xHarbour  | BCC 7.3 32-bit   | estável  | ? | ...   |
| xHarbour  | BCC 7.3 64-bit   | estável  | ? | ...   |
| xHarbour  | BCC 7.7 32-bit   | ?        | ? | ...   |
| xHarbour  | BCC 7.7 64-bit   | instável | ? | ...   |
| Harbour++ | MinGW32          | estável  | ? | ...   |
| Harbour++ | MinGW64          | estável  | ? | requer flag -fpermissive |
| Harbour++ | MSVC32           | estável  | ? | ... |
| Harbour++ | MSVC64           | estável  | ? | ... |
| Harbour++ | Clang32          | estável  | ? | ... |
| Harbour++ | Clang64          | estável  | ? | requer flag -fpermissive |
| Harbour++ | BCC 7.3 32-bit   | ?        | ? | ...   |
| Harbour++ | BCC 7.3 64-bit   | estável  | ? | ...   |

? = testes pendentes

A estabilidade se refere ao resultado obtido com os programas da pasta 'tests'.

Problemas na compilação ou na utilização podem ser informados na seção
'Issues'. O assunto será revisado o mais breve possível.

## Problemas conhecidos

xHarbour com BCC64 7.7  
Esta combinação apresenta instabilidade no acesso à estrutura DRAWITEMSTRUCT, utilizada na mensagem
WM_DRAWITEM. Embora funcione corretamente com outros compiladores, não funciona quando se trata desta
versão específica do BCC64. A solução, por enquanto, seria evitar esta combinação.

# Notas

Este repositório é um 'fork' (projeto derivado). O código-fonte original poderá
ser encontrado nos link's abaixo:

https://sourceforge.net/projects/hwgui/  
https://sourceforge.net/p/hwgui/code/1908/tree/  
