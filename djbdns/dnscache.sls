# read pillar
{%- set DNSCACHE = salt['pillar.get']('djbdns:dnscache', {}) -%}
{%- set SETTINGS    = DNSCACHE.get('settings', {}) -%}
{%- set CLIENT_LIST = DNSCACHE.get('clients',  []) -%}
{%- set ZONE_DICT   = DNSCACHE.get('zones',    {}) -%}
{%- set LOCATION = SETTINGS.get('LOCATION', '/etc/sv/dnscache') -%}

# packages
dnscache_packages:
  pkg.installed:
    - pkgs:
      - djbdns
      - dnscache-run

# service
dnscache:
  service:
    - running
    - provider: daemontools
    - require:
      - pkg : dnscache_packages

# settings
{{ LOCATION }}/env:
  file.directory:
    - require:
      - pkg: dnscache_packages
    - clean: True
{% macro render_env(FILENAME, CONTENTS) %}
{{ LOCATION }}/env/{{ FILENAME }}:
  file.managed:
    - contents: "{{ CONTENTS }}"
    - require_in:
      - file: {{ LOCATION }}/env
    - watch_in:
      - service: dnscache
{% endmacro %}
{{ render_env('CACHESIZE', SETTINGS.get('CACHESIZE', '1000000'   )) }}
{{ render_env('DATALIMIT', SETTINGS.get('DATALIMIT', '3000000'   )) }}
{{ render_env('IP',        SETTINGS.get('IP',         '127.0.0.1')) }}
{{ render_env('IPSEND',    SETTINGS.get('IPSEND',     '0.0.0.0'  )) }}
{{ render_env('ROOT',      LOCATION + '/root') }}

# clients
{{ LOCATION }}/root/ip:
  file.directory:
    - clean: True
    - require:
      - pkg: dnscache_packages
    - watch_in:
      - service: dnscache
{% macro render_client(CLIENT) %}
{{ LOCATION }}/root/ip/{{ CLIENT }}:
  file.managed:
    - require_in:
      - file: {{ LOCATION }}/root/ip
    - watch_in:
      - service: dnscache
{% endmacro %}
{% for CLIENT in CLIENT_LIST -%}
{{ render_client(CLIENT) }}
{% endfor %}

# zones
{{ LOCATION }}/root/servers:
  file.directory:
    - clean: True
    - require:
      - pkg: dnscache_packages
    - watch_in:
      - service: dnscache
{{ LOCATION }}/root/servers/@:
  file.managed:
    - source: salt://djbdns/files/@
    - require_in:
      - file: {{ LOCATION }}/root/servers
    - watch_in:
      - service: dnscache
{% macro render_zone(NAME, IP_LIST) %}
{{ LOCATION }}/root/servers/{{ NAME }}:
  file.managed:
    - contents: "{{ IP_LIST|join('\n') }}\n"
    - require_in:
      - file: {{ LOCATION }}/root/servers
    - watch_in:
      - service: dnscache
{% endmacro %}
{% for ZONE_NAME in ZONE_DICT -%}
{{ render_zone(ZONE_NAME,ZONE_DICT[ZONE_NAME]) }}
{% endfor %}
