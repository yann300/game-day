// Right click on the script name and hit "Run" to execute
(async () => {
    try {
        console.log('add Track')
    
        const gameDayAddress = '0x0813d4a158d06784FDB48323344896B2B1aa0F85'
        const contractName = 'GameDay'
        
        const trackName = 'test'
        const trackDescription = 'desc'
        const hashes = ["0x25116287a1b258617d968f41e4d3aa85990958d404d4afeef9d2d674aa552d15","0xecd0ff09c6aa000dbb4711bca6e0f66b81e0c2b3e26afd6884ae302ba2432007"]
        const descriptions = ["desc 1", "desc 2"]
        const prizeLocation = "0xd9145CCE52D386f254917e481eB44e9943F39138"
        const prizeCall = "0x25116287a1b258617d968f41e4d3aa85990958d404d4afeef9d2d674aa552d15"

        // Note that the script needs the ABI which is generated from the compilation artifact.
        // Make sure contract is compiled and artifacts are generated
        const artifactsPath = `artifacts/${contractName}.json` // Change this for different path
    
        const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))
        // 'web3Provider' is a remix global variable object
        const signer = (new ethers.providers.Web3Provider(web3Provider)).getSigner()
    
        let contract = new ethers.Contract(gameDayAddress, metadata.abi, signer);
        
        const trackRegisteredFn = (...args)=> {
            console.log(args)
        }
        contract.on('trackRegistered', trackRegisteredFn)
        let registerTrack = await contract.registerTrack(
            trackName, 
            trackDescription, 
            hashes, 
            descriptions,
            prizeLocation,
            prizeCall)

        await registerTrack.wait()
        console.log(JSON.stringify(registerTrack))
        console.log('done.')

        setTimeout(() => {
            contract.off('trackRegistered', trackRegisteredFn)
        }, 10000)
    } catch (e) {
        console.log(e.message)
    }
})()