import os
import re
from pathlib import Path
from datetime import datetime

def parse_html_file(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
    
    news_items = []
    
    news_pattern = r'<div class="news-item">.*?<div class="news-title">.*?<a[^>]*href="([^"]*)"[^>]*class="news-link"[^>]*>([^<]*)</a>.*?</div>'
    
    for match in re.finditer(news_pattern, content, re.DOTALL):
        link = match.group(1).strip()
        title = match.group(2).strip()
        
        item_block = match.group(0)
        
        time_match = re.search(r'<span class="time-info">([^<]*)</span>', item_block)
        time_range = time_match.group(1).strip() if time_match else ""
        
        count_match = re.search(r'<span class="count-info">([^<]*)</span>', item_block)
        count = count_match.group(1).strip() if count_match else ""
        
        source_match = re.search(r'<div class="standalone-name">([^<]*)</div>', item_block)
        source = source_match.group(1).strip() if source_match else "未知"
        
        news_items.append({
            "title": title,
            "link": link,
            "time_range": time_range,
            "count": count,
            "source": source
        })
    
    return news_items

def deduplicate_news(all_news):
    seen = set()
    unique_news = []
    
    for news in all_news:
        link = news.get("link", "")
        title = news.get("title", "")
        key = link or title
        
        if key and key not in seen:
            seen.add(key)
            unique_news.append(news)
    
    return unique_news

def analyze_news(news_list):
    source_stats = {}
    for news in news_list:
        source = news.get("source", "未知")
        source_stats[source] = source_stats.get(source, 0) + 1
    return source_stats

def generate_report(news_dir=None, output_file=None):
    if news_dir is None:
        news_dir = Path(r"D:\ks_ws\git-root\TrendRadar-mod-for-ks1\output\html")
    else:
        news_dir = Path(news_dir)
    
    if output_file is None:
        output_file = news_dir / "新闻汇总报告.txt"
    
    today = datetime.now().strftime("%Y-%m-%d")
    date_dir = news_dir / today
    
    if not date_dir.exists():
        print(f"目录 {date_dir} 不存在")
        return
    
    html_files = sorted(date_dir.glob("*.html"))
    print(f"找到 {len(html_files)} 个HTML文件")
    
    all_news = []
    for html_file in html_files:
        print(f"解析: {html_file.name}")
        news = parse_html_file(html_file)
        print(f"  提取到 {len(news)} 条新闻")
        all_news.extend(news)
    
    print(f"\n原始新闻总数: {len(all_news)}")
    
    unique_news = deduplicate_news(all_news)
    print(f"去重后新闻数: {len(unique_news)}")
    
    source_stats = analyze_news(unique_news)
    
    with open(output_file, "w", encoding="utf-8") as f:
        f.write("=" * 60 + "\n")
        f.write(f"新闻汇总报告 - {today}\n")
        f.write("=" * 60 + "\n\n")
        
        f.write(f"数据来源文件:\n")
        for hf in html_files:
            f.write(f"  - {hf.name}\n")
        f.write(f"\n原始新闻总数: {len(all_news)}\n")
        f.write(f"去重后新闻数: {len(unique_news)}\n")
        f.write(f"去除重复: {len(all_news) - len(unique_news)} 条\n\n")
        
        f.write("-" * 40 + "\n")
        f.write("各平台新闻数量:\n")
        f.write("-" * 40 + "\n")
        for source, count in sorted(source_stats.items(), key=lambda x: -x[1]):
            f.write(f"  {source}: {count} 条\n")
        
        f.write("\n" + "-" * 40 + "\n")
        f.write("新闻列表:\n")
        f.write("-" * 40 + "\n")
        
        for i, news in enumerate(unique_news, 1):
            title = news.get("title", "无标题")
            link = news.get("link", "")
            source = news.get("source", "未知")
            count = news.get("count", "")
            time_range = news.get("time_range", "")
            
            f.write(f"\n{i}. {title}\n")
            if source != "未知":
                f.write(f"   来源: {source}\n")
            if count:
                f.write(f"   出现次数: {count}\n")
            if time_range:
                f.write(f"   时间范围: {time_range}\n")
            if link:
                f.write(f"   链接: {link}\n")
    
    print(f"\n报告已生成: {output_file}")
    return unique_news

if __name__ == "__main__":
    generate_report()
