import cmd from 'cmdish'
import fs from 'fs'

const buildSourceZip = async () => {

  //
  // Load vars
  //
  const varsString = await fs.promises.readFile(`${__dirname}/tfvars.json`, 'utf-8')
  const vars = JSON.parse(varsString)

  //
  // Read and update the buildspec
  //
  const buildspecTemplate = await fs.promises.readFile(`${__dirname}/buildspec.yml`, 'utf-8')
  const buildspec = buildspecTemplate.replace('{{command}}', vars.command)
  await fs.promises.writeFile(`${__dirname}/source/buildspec.yml`, buildspec)

  //
  // Install dependencies
  //
  await cmd('yarn', { cwd: `${__dirname}/source` })

  //
  // Generate zip
  //
  await cmd(`zip -q -r ${__dirname}/source.zip *`, {
    cwd: `${__dirname}/source`
  })
}

buildSourceZip()