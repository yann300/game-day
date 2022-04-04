// Right click on the script name and hit "Run" to execute
(async () => {
    try {
        console.log('generate Keccak')
    
        const gameDayAddress = '0x3fbE213f0B7F1E28331D80d7a41c8A5989325f18'
        const contractName = 'GameDay'
       
        const inputs = [
            "0x746573749a",
            "0x746573748b"
        ]

        // Note that the script needs the ABI which is generated from the compilation artifact.
        // Make sure contract is compiled and artifacts are generated
        const artifactsPath = `artifacts/${contractName}.json` // Change this for different path
    
        const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))
        // 'web3Provider' is a remix global variable object
        const signer = (new ethers.providers.Web3Provider(web3Provider)).getSigner()
    
        let contract = new ethers.Contract(gameDayAddress, metadata.abi, signer);
        
        let registerTrack = await contract.keccak256Of(inputs)

        // await registerTrack.wait()
        console.log(JSON.stringify(registerTrack))
        console.log('done.')
    } catch (e) {
        console.log(e.message)
    }
})()