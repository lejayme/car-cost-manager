#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""简单的 Markdown 转 HTML 转换器"""

import re

def md_to_html(md_path, html_path):
    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 标题
    content = re.sub(r'^# (.+)$', r'<h1>\1</h1>', content, flags=re.MULTILINE)
    content = re.sub(r'^## (.+)$', r'<h2>\1</h2>', content, flags=re.MULTILINE)
    content = re.sub(r'^### (.+)$', r'<h3>\1</h3>', content, flags=re.MULTILINE)
    content = re.sub(r'^#### (.+)$', r'<h4>\1</h4>', content, flags=re.MULTILINE)
    
    # 粗体
    content = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', content)
    
    # 代码
    content = re.sub(r'`([^`]+)`', r'<code>\1</code>', content)
    
    # 列表
    content = re.sub(r'^- (.+)$', r'<li>\1</li>', content, flags=re.MULTILINE)
    
    # 表格处理（简化）
    lines = content.split('\n')
    new_lines = []
    in_table = False
    for line in lines:
        if line.startswith('|---'):
            continue
        if line.startswith('|'):
            if not in_table:
                new_lines.append('<table>')
                in_table = True
            cells = [c.strip() for c in line.split('|')[1:-1]]
            new_lines.append('<tr>' + ''.join(f'<td>{c}</td>' for c in cells) + '</tr>')
        else:
            if in_table:
                new_lines.append('</table>')
                in_table = False
            new_lines.append(line)
    if in_table:
        new_lines.append('</table>')
    content = '\n'.join(new_lines)
    
    # 分隔线
    content = content.replace('---', '<hr>')
    
    # 段落
    content = content.replace('\n\n', '</p><p>')
    
    html = f'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CarCost 需求文档</title>
    <style>
        body {{ 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; 
            max-width: 900px; 
            margin: 0 auto; 
            padding: 40px 20px; 
            line-height: 1.6;
            background: #fff;
            color: #24292e;
        }}
        h1 {{ color: #24292e; border-bottom: 2px solid #eaecef; padding-bottom: 0.3em; }}
        h2 {{ color: #24292e; border-bottom: 1px solid #eaecef; padding-bottom: 0.3em; margin-top: 24px; }}
        h3 {{ color: #24292e; margin-top: 20px; }}
        code {{ background: #f6f8fa; padding: 2px 6px; border-radius: 3px; font-family: Consolas, monospace; }}
        pre {{ background: #f6f8fa; padding: 16px; border-radius: 6px; overflow-x: auto; }}
        table {{ border-collapse: collapse; width: 100%; margin: 16px 0; }}
        th, td {{ border: 1px solid #dfe2e5; padding: 8px 12px; text-align: left; }}
        th {{ background: #f6f8fa; font-weight: 600; }}
        tr:nth-child(even) {{ background: #f8f9fa; }}
        hr {{ border: none; border-top: 1px solid #eaecef; margin: 24px 0; }}
        li {{ margin: 4px 0; margin-left: 20px; }}
        ul {{ padding-left: 20px; }}
        strong {{ color: #0366d6; }}
    </style>
</head>
<body>
{content}
</body>
</html>
'''
    
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(html)
    
    print(f"[OK] HTML 已生成：{html_path}")

if __name__ == '__main__':
    md_to_html(
        r'C:\Users\lejay\.openclaw\workspace\car-cost-manager\requirements.md',
        r'C:\Users\lejay\.openclaw\workspace\car-cost-manager\requirements.html'
    )
    md_to_html(
        r'C:\Users\lejay\.openclaw\workspace\car-cost-manager\quickstart.md',
        r'C:\Users\lejay\.openclaw\workspace\car-cost-manager\quickstart.html'
    )
