// Help Rembrandt hide clues in his paintings
(async () => {
  try {
      console.log('Running Rembrandt\'s the Nightwatch script...')
      const clue = 'Banning Cocq’s company of Kloveniers (or Musketeers). Militia Company of District II']
      const accounts = await web3.eth.getAccounts()

      // Let's hide the first clue
      const account = web3.utils.toChecksumAddress(accounts[0])
  
      console.log(`account: ${account}`)
      
      web3.eth.personal.sign(clue, account, (err, signature) => {
          if (err) console.log('Oops! Couldn\'t hide clues. Something went wrong while painting.')
          else updateContract(account, signature)
      })
      // Try to hide more clues ...
      // DIY: Follow process above to hide more clues
      // More clues are listed below
      // * Rival painters of the 17th Century in Holland possibly Peter Paul Rubens
      // * A guard accidentally firing his musket
      // * A drinking horn
      // * A damsel
      // * A right handed glove used to slap someone for a challenge (a duel)
      // * An upturned chicken
      // Check https://github.com/ryestew/gamedayRemix/blob/main/README.md for more.
  } catch (e) {
      console.log(e.message)
  }
})()

async function updateContract (account: string, signature: string) {
  const nightwatchAddress = '0xd8218fd479b58bcdbd39e542bdb344b1400f4456'
  const contractName = 'The_Nightwatch'
  const artifactsPath = `artifacts/${contractName}.json` // Change this for different path
  const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))
  let contract = new web3.eth.Contract(metadata.abi, nightwatchAddress)
  
  console.log('sending transaction...')
  await contract.methods.updateSignature(signature).send({
      from: account
  })
  console.log('contract updated with signature!')
  remix.call('notification', 'modal', {
      id: 'notifySignature',
      title: 'Success!',
      message: `Congratulations! You\'ve helped Rembrandt to hide a clue in his painting. Signature: ${signature}`,
      okLabel: 'OK'
  })
  console.log('Congratulations! You\'ve helped Rembrandt to hide a clue in his painting. The Nightwatch!')
}