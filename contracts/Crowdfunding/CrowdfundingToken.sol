// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title CrowdfundingToken
 * @dev ERC20 Token para proyectos de Crowdfunding
 */

contract CrowdfundingToken is ERC20, Ownable{
    uint256 public cap;
    uint256 public saleStart;
    uint256 public saleEnd;
    uint256 public rate; // Tokens por ETH

    event TokensPurchased(address indexed purchaser, uint256 amountSpent, uint256 tokensMinted);
    event SaleFinalized();
    
    constructor(
        string memory name, // Nombre de token
        string memory symbol, // Simbolo de token - abreviación
        uint256 initialMint, // Cantidad de tokens que se van a mintear inicialmente
        uint256 _cap, // Limite de tokens que pueden existir
        uint256 _saleStart, // Define la fecha/hora de inicio de la venta de tokens
        uint256 _saleEnd, // Indica el fin de la venta de tokens
        uint256 _rate // Representa el precio de cada token en la venta de crowdfunding
    ) ERC20(name, symbol) Ownable(msg.sender) {
        require(_cap > 0, "El limite de tokens debe ser mayor que cero");
        require(_saleStart < _saleEnd, "El inicio de la venta debe ser antes del final de la venta");
        require(_rate > 0, "La tasa debe ser mayor que cero");

        cap = _cap * 10 ** decimals();
        saleStart = _saleStart;
        saleEnd = _saleEnd;
        rate = _rate;

         // Asignar tokens iniciales al propietario
        _mint(msg.sender, initialMint * 10 ** decimals());
    }


     /**
     * @dev Comprar tokens durante la venta
     */

    function buyTokens() external payable {
        require(block.timestamp >= saleStart, "La venta aun no ha comenzado");
        require(block.timestamp <= saleEnd, "La venta ha finalizado");
        require(msg.value > 0, "Debe enviar ETH para comprar tokens");

        uint256 tokensToMint = msg.value * rate;
        require(totalSupply() + tokensToMint <= cap, "Limite excedido");

         _mint(msg.sender, tokensToMint);
        emit TokensPurchased(msg.sender, msg.value, tokensToMint);
    }


    /**
     * @dev Finalizar la venta y retirar fondos
     */

    function finalizeSale() external onlyOwner {
        require(block.timestamp > saleEnd, "Venta aun no finalizada");
        payable(owner()).transfer(address(this).balance);
        emit SaleFinalized();
    }


    /**
     * @dev Función para mintear tokens adicionales (solo el propietario)
    */

    function mint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= cap, "Limite excedido");
        _mint(to, amount);
    }


    /**
     * @dev Verificar si la venta está activa
    */

    function isSaleActive() public view returns (bool) {
        return block.timestamp >= saleStart && block.timestamp <= saleEnd;
    }



    /**
     * @dev Sobrescribir fuunciones para incluir restricciones
     */

    // Sobrescribiendo la función transfer
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        // Lógica de validación
        require(to != address(0), "No se permite la transferencia a la direccion cero");
        require(amount > 0, "El importe de la transferencia debe ser mayor a cero");

        // Llamada a la función del contrato base
        return super.transfer(to, amount);
    }

    // Sobrescribiendo la función transferFrom
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        // Lógica de validación
        require(to != address(0), "No se permite la transferencia a la direccion cero");
        require(amount > 0, "El importe de la transferencia debe ser mayor a cero");

        // Llamada a la función del contrato base
        return super.transferFrom(from, to, amount);
    }
}