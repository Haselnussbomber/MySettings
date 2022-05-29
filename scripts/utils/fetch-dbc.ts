export async function fetchDBCVersions(dbcName: string) {
	const res = await fetch(`https://api.wow.tools/databases/${dbcName}/versions`);
	return await res.json();
}

export default async function fetchDBC<T>(dbcName: string, build?: string) {
	if (!build) {
		const versions = await fetchDBCVersions(dbcName);
		build = versions.shift();
	}

	const res = await fetch(`https://wow.tools/dbc/api/export/?name=${dbcName}&build=${build}&useHotfixes=true`);
	const csv = await res.text();

	//! https://stackoverflow.com/a/53774647
	const entries = csv.trim().split("\n").map(line => line.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/));
	const headers = entries.shift() as (keyof T)[];

	const data: T[] = [];

	for (const entry of entries) {
		const obj = {} as T;
		for (let i = 0; i < entry.length; i++) {
			const value = entry[i];
			const valueNum = parseInt(value, 10);
			// @ts-ignore - i don't know how to tell TS headers is a keyof T array
			obj[headers[i]] = valueNum.toString() === value ? valueNum : value;
		}
		data.push(obj);
	}

	return { build, data };
}
