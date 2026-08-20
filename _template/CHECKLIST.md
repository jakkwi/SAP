# Starting a new mini project

Copy this folder, then work top to bottom. Nothing in CI needs touching -
`.github/workflows/ci.yml` discovers every top-level folder that contains a
`package.json`, and folders starting with `_` are skipped.

```bash
cp -r _template zjk_yourname
cd zjk_yourname
rm CHECKLIST.md
npm install          # generates package-lock.json, which CI needs for npm ci
```

## Rename

- [ ] `package.json` → `name`, `description`
- [ ] `src/package.devc.xml` → `CTEXT`
- [ ] `README.md` → title, summary, usage, package name, layout block
- [ ] Folder name matches the ABAP package, lower case (`zjk_alpha` → `ZJK_ALPHA`)

## Write the code

- [ ] `src/zcl_jk_<name>.clas.abap` - the class
- [ ] `src/zcl_jk_<name>.clas.xml` - abapGit metadata, `WITH_UNIT_TESTS` set to `X`
- [ ] `src/zcl_jk_<name>.clas.testclasses.abap` - ABAP Unit tests
- [ ] Follow [CONVENTIONS.md](../CONVENTIONS.md)

## Verify before pushing

- [ ] `npm test` passes locally
- [ ] `package-lock.json` is committed - CI runs `npm ci` and fails without it
- [ ] Every public method has at least one test
- [ ] Add a row to the project table in the [root README](../README.md)
