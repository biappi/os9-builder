import re
from pprint import pprint

def sym(address, name):
    return f'<comment address="{address}" color="16711680">{name}</comment>'

def total(comments):
    return f"""
    <?xml version="1.0"?>
    <!-- This file is autogenerated; comments and unknown tags will be stripped -->
    <mamecommentfile version="1">
        <system name="fake68">
            <cpu tag=":maincpu">
    {comments}
            </cpu>
        </system>
    </mamecommentfile>
    """

originalfile = open("romboot.map", "r").read()
symbols = re.findall('(\w{1,10}) +([A-Z]{3}) ([0-9a-fA-F]{8})', originalfile)
all_comments = [sym(int(addr, 16), f"{name}    -- {typ}") for name, typ, addr in symbols]
comments_string = "\n".join(all_comments)
comments_file = total(comments_string)
print(comments_file)
