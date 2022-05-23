import path from 'path'
import octo from 'octokit-downloader'

const downloadBridgeSource = async () => {

    await octo.download({
        from: '',
        to: path.join(__dirname, 'bridge.zip'),
        unzip: true
      })
}

downloadBridgeSource()