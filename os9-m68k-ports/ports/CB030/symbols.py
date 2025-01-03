import re

filename = "CMDS/BOOTOBJS/ROMBUG/romboot.map"
originalfile = open(filename, "r").read()
symbols = re.findall('(\w{1,10}) +([A-Z]{3}) ([0-9a-fA-F]{8})', originalfile)
all_comments = [(int(addr, 16), name, typ) for name, typ, addr in symbols]

for a, n, t in all_comments:
    print(f"{a:08x} {n}")

#import re
#from pprint import pprint
#
#x = open("romboot.map", "r").read()
#
#def sym(address, name):
#    return f'<comment address="{address}" color="16711680">{name}</comment>'
#
#def total(comments):
#    return f"""
#    <?xml version="1.0"?>
#    <!-- This file is autogenerated; comments and unknown tags will be stripped -->
#    <mamecommentfile version="1">
#        <system name="fake68">
#            <cpu tag=":maincpu">
#    {comments}
#            </cpu>
#        </system>
#    </mamecommentfile>
#    """
#
#xx = [re.findall('\w{1,10} +[A-Z]{3} [0-9a-fA-F]{8}', i) for i in x]
#pprint(xx)

