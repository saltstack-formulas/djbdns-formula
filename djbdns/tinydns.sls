# read pillar
{%- set TINYDNS = salt['pillar.get']('djbdns:tinydns', {})     -%}
{%- set SETTINGS = TINYDNS.get('settings', {})                 -%}
{%- set LOCATION = SETTINGS.get('LOCATION', '/etc/sv/tinydns') -%}
{%- set IP = SETTINGS.get('IP', '127.0.0.1')                   -%}
{%- set DATA = TINYDNS.get('data')                             -%}
# installation
Gdnslog:
  user.present:
    - createhome: False
    - password: !
    - shell: /bin/false

Gtinydns:
  user.present:
    - createhome: False
    - password: !
    - shell: /bin/false
    - require:
      - pkg: tinydns_packages

/usr/local/bin/tinydns-conf.sh:
  cmd.wait:
    - shell: /bin/sh
    - require:
      - user: Gdnslog
      - user: Gtinydns
    - watch:
      - pkg: tinydns_packages
  file.managed:
    - source: salt://djbdns/files/tinydns-conf.sh
    - mode: 744
    - template: jinja
    - context:
        LOCATION: {{ LOCATION }}
        IP: {{ IP }}

tinydns_packages:
  pkg.installed:
    - pkgs:
      - djbdns
      - daemontools
      - daemontools-run
    - require:
      - file: /usr/local/bin/tinydns-conf.sh


# service
/etc/service:
  file.directory:
    - user: root
    - group: root
    - require:
        - pkg: tinydns_packages

/etc/service/tinydns:
  file.symlink:
    - user: root
    - group: root
    - target: {{ LOCATION }}
    - require:
        - file: /etc/service

tinydns:
  service.running:
    - provider: daemontools
    - require:
        - pkg: tinydns_packages
        - file: /usr/local/bin/tinydns-conf.sh
        - file: /etc/service/tinydns

# config
{{ LOCATION }}/env:
  file.directory:
    - require:
      - pkg: tinydns_packages
    - clean: True

{% macro render_env(FILENAME, CONTENTS) %}
{{ LOCATION }}/env/{{ FILENAME }}:
  file.managed:
    - contents: "{{ CONTENTS }}"
    - require_in:
      - file: {{ LOCATION }}/env
    - watch_in:
      - service: tinydns
{% endmacro %}
{{ render_env('IP',   IP                ) }}
{{ render_env('ROOT', LOCATION + '/root') }}

# data
/usr/bin/make:
  cmd.wait:
    - cwd: {{ LOCATION }}/root
    - watch:
      - file: {{ LOCATION }}/root/data

{{ LOCATION }}/root/data:
  file.managed:
    - source: {{ DATA }}
    - mode: 644
    - watch_in:
      - service: tinydns
