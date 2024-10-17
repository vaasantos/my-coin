// SPDX-License-Identifier: GPL-3.0
// Define a licença sob a qual o contrato é distribuído

pragma solidity 0.8.26;
// Define a versão do compilador Solidity que será usada para compilar o contrato

// Interface IRC20 define o padrão de um token ERC-20
interface IRC20 {
    // Retorna o total de tokens emitidos
    function totalSupply() external view returns (uint256);

    // Retorna o número de casas decimais do token
    function decimals() external view returns (uint8);

    // Retorna o símbolo do token (ex: BTC, ETH)
    function symbol() external view returns (string memory);

    // Retorna o nome do token (ex: Bitcoin, Ethereum)
    function name() external view returns (string memory);

    // Retorna o endereço do dono do contrato/token
    function getOwner() external view returns (address);

    // Retorna o saldo de tokens de um endereço específico
    function balanceOf(address account) external view returns (uint256);

    // Transfere tokens do remetente para o destinatário
    function transfer(address recipient, uint256 amount) external returns (bool);

    // Retorna a quantidade de tokens que um `spender` pode gastar do saldo de um `owner`
    function allowance(address _owner, address spender) external view returns (uint256);

    // Permite que um `spender` gaste uma quantidade específica de tokens do `owner`
    function approve(address spender, uint256 amount) external returns (bool);

    // Transfere tokens de um `sender` para um `recipient`, desde que autorizado pelo `owner`
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Evento emitido quando tokens são transferidos
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Evento emitido quando uma autorização para gastar tokens é concedida
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Implementação do contrato MyToken baseado no padrão IRC20
contract MyToken is IRC20 {
    // Define o total de tokens emitidos (100 milhões com 10 casas decimais)
    uint256 public totalSupply = 100000000 * 10**10;

    // Define o número de casas decimais (10)
    uint8 public decimals = 10;

    // Define o símbolo do token
    string public symbol = "MT";

    // Define o nome do token
    string public name = "MyToken";

    // Endereço do dono do contrato/token
    address private _tokenOwner;

    // Mapeamento que guarda o saldo de tokens de cada endereço
    mapping(address => uint256) private _balance;

    // Mapeamento que define quanto um endereço pode gastar do saldo de outro
    mapping(address => mapping(address => uint256)) private _allowances;

    // Construtor que define o criador do contrato como o dono e atribui o totalSupply para ele
    constructor() {
        _tokenOwner = msg.sender;
        _balance[_tokenOwner] = totalSupply;
    }

    // Função para retornar o endereço do dono do contrato
    function getOwner() external view returns (address) {
        return _tokenOwner;
    }

    // Função para retornar o saldo de um endereço específico
    function balanceOf(address account) external view returns (uint256) {
        return _balance[account];
    }

    // Função para transferir tokens do remetente para um destinatário
    function transfer(address recipient, uint256 amount) external returns (bool) {
        // Subtrai o valor da conta do remetente
        _balance[msg.sender] -= amount;

        // Adiciona o valor na conta do destinatário
        _balance[recipient] += amount;

        // Emite o evento Transfer para registrar a operação
        emit Transfer(msg.sender, recipient, amount);

        return true;
    }

    // Função para verificar a quantidade de tokens que um endereço pode gastar do saldo de outro
    function allowance(address _owner, address spender) external view returns (uint256) {
        return _allowances[_owner][spender];
    }

    // Função para permitir que um terceiro gaste tokens do remetente
    function approve(address spender, uint256 amount) external returns (bool) {
        // Define a quantidade que o `spender` pode gastar do saldo do remetente
        _allowances[msg.sender][spender] = amount;

        // Emite o evento Approval para registrar a permissão
        emit Approval(msg.sender, spender, amount);

        return true;
    }

    // Função para transferir tokens de um endereço para outro, desde que autorizado
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        // Subtrai a permissão (allowance) do `sender`
        _allowances[sender][msg.sender] -= amount;

        // Subtrai o saldo do `sender`
        _balance[sender] -= amount;

        // Adiciona o saldo ao `recipient`
        _balance[recipient] += amount;

        // Emite o evento Transfer para registrar a operação
        emit Transfer(sender, recipient, amount);

        return true;
    }
}
