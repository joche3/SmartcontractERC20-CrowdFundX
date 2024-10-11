const hre = require("hardhat");

async function main() {

    // Parámetros del contrato
    const name = "CrowdFundX Token";
    const symbol = "CFT";
    const initialMint = 10000; // Tokens iniciales
    const cap = 1000000; // Límite total de tokens
    const saleStart = Math.floor(Date.now() / 1000) + 60; // Venta empieza en 1 minuto
    const saleEnd = saleStart + (7 * 24 * 60 * 60); // Venta dura 7 días
    const rate = 1000; // 1000 tokens por 1 ETH

    // Obtener el contrato para desplegar
    const CrowdfundingToken = await hre.ethers.getContractFactory("CrowdfundingToken");

    // Desplegar el contrato
    const crowdfundingToken = await CrowdfundingToken.deploy(
        name,
        symbol,
        initialMint,
        cap,
        saleStart,
        saleEnd,
        rate
    );

    await crowdfundingToken.waitForDeployment();

    console.log("CrowdfundingToken desplegado en:", crowdfundingToken.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
})