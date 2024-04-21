import { BaseCommand } from '@adonisjs/core/ace'
import type { CommandOptions } from '@adonisjs/core/types/ace'
import { readFile, rename, writeFile } from 'node:fs/promises'

export default class MakeSecrets extends BaseCommand {
  static commandName = 'apply:secrets'
  static description = 'Applies secrets into source files'

  static options: CommandOptions = {}

  async run() {
    const files = ['.env', '../lib/constants.local.dart', '../web/config.js', '../strings.xml']
    let secrets: Record<string, string>
    try {
      const secretsData = await readFile('./secrets.json').then((v) => v.toString())
      secrets = JSON.parse(secretsData)
    } catch (err) {
      if (err.code === 'ENOENT') {
        await writeFile('./secrets.json', '{}')
        secrets = {}
      } else throw err
    }

    const inputData = new Map(
      await Promise.all(
        files.map(
          async (file) =>
            [file, await readFile(file + '.example').then((content) => content.toString())] as const
        )
      )
    )

    const outputData = new Map<string, string>()

    const missingKeys = new Set<string>()
    for (const [name, input] of inputData) {
      const output = input.replace(/\$([a-zA-Z]+)/g, (_, key) => {
        if (!(key in secrets) || secrets[key] === '') {
          missingKeys.add(key)
          return ''
        }

        return secrets[key]
      })

      outputData.set(name, output)
    }

    if (missingKeys.size !== 0) {
      this.logger.error('Missing secrets: ' + [...missingKeys].join(', '))
      for (const missing of missingKeys) {
        secrets[missing] = ''
        await writeFile('./secrets.json', JSON.stringify(secrets, null, 2))
      }
      return
    }

    await Promise.all(
      [...outputData].map(async ([name, output]) => {
        await writeFile(name, output)
      })
    )

    await rename('../strings.xml', '../android/app/src/main/res/values/strings.xml')
  }
}
