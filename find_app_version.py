#!/usr/bin/env python3
import requests
import bs4
import argparse


def get_apps():
    apps = []
    with open('Dockerfile', 'r') as f:
        for line in f.read().splitlines():
            if line.startswith('ARG') and "_version" in line:
                apps.append(line.split(' ')[1].split('_version')[0])
    return apps


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--version', '-v', required=True)
    args = parser.parse_args()
    version = args.version
    for app in get_apps():
        url = f'https://apps.nextcloud.com/apps/{app}'
        try:
            res = requests.get(url)
            soup = bs4.BeautifulSoup(res.text, 'html.parser')
            try:
                table = soup.find_all('table')[0]
                rows = table.find_all('tr')
                for row in rows:
                    cols = row.find_all('td')
                    if len(cols) == 0:
                        continue
                    if cols[0].text == version:
                        print(f'ARG {app}_version={cols[1].text}')
                        break
            except IndexError:
                continue
        except requests.exceptions.HTTPError:
            continue


if __name__ == '__main__':
    main()
