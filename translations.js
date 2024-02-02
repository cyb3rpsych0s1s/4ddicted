const fs = require('fs/promises')
const path = require('path')
const yaml = require('js-yaml')
const locales = [
    'en-us',
    'fr-fr',
]
const archive = async () => {
    const at = '.\\archives\\Addicted.Translations\\source\\raw'
    const dir = await fs.readdir(at)
    let content
    const lines = []
    for (const file of dir) {
        if ((await fs.stat(`${at}\\${file}`)).isFile()) {
            console.log(`parsing ${file}...`)
            content = await fs.readFile(`${at}\\${file}`)
            content = JSON.parse(content)
            const { Data: { RootChunk: { root: { Data: { entries } } } } } = content
            for (let { secondaryKey: key, femaleVariant: female, maleVariant: male } of entries) {
                male = male?.trim()
                female = female?.trim()
                if (male.length > 0 && male !== female) {
                    lines.push(`${key}|${female}|${male}`)
                } else {
                    lines.push(`${key}|${female}|`)
                }
            }
            await fs.writeFile(`./${path.parse(path.parse(file).name).name}.csv`, lines.reduce((acc, current) => `${acc}\n${current}`, 'secondaryKey|femaleVariant|maleVariant'))
            console.log(`wrote ${lines.length} translations to ${path.parse(path.parse(file).name).name}.csv`)
        }
    }
    console.log('finished parsing archive files!')
}
const audioware = async () => {
    const at = `.\\audioware`
    const dir = await fs.readdir(at)
    const lines = []
    const keys = []
    let idx = 0
    for (const locale of locales) {
        console.log(`parsing files for ${locale}...`)
        lines.length = 0
        for (const file of dir) {
            if ((await fs.stat(`${at}\\${file}`)).isFile()) {
                const { voices } = yaml.load(await fs.readFile(`${at}\\${file}`, 'utf8'))
                for (const key in voices) {
                    if (!keys.includes(key)) {
                        if (idx > 0) { console.warn(`missing key '${key}' ?`)}
                        keys.push(key)
                    }
                    let { fem: female, male } = voices[key]
                    female = female[locale]?.subtitle.trim()
                    male = male[locale]?.subtitle.trim()
                    if (male && male.length > 0 && male !== female) {
                        lines.push(`${key}|${female}|${male}`)
                    } else if (female) {
                        lines.push(`${key}|${female}|`)
                    }
                }
            }
        }
        await fs.writeFile(`./audioware-${locale}.csv`, lines.reduce((acc, current) => `${acc}\n${current}`, 'secondaryKey|femaleVariant|maleVariant'))
        console.log(`wrote ${lines.length} translations to audioware-${locale}.csv`)
        idx += 1
    }
    console.log('finished parsing audioware files!')
}
archive().then(() => audioware()).catch(console.error)