import re
import sys

def parse_dex():
    try:
        with open("c:/Users/User/Desktop/Script/script/Dex e REMOTES", "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
    except Exception as e:
        print(f"Error reading file: {e}")
        return

    # Find typical remote events or functions
    events = set(re.findall(r'Events:WaitForChild\("([^"]+)"\)', content))
    functions = set(re.findall(r'Functions:WaitForChild\("([^"]+)"\)', content))
    
    # Also find general FireServer/InvokeServer strings just in case
    # This might capture names of remotes or variables
    fires = set(re.findall(r':?FireServer\(([^)]*)\)', content))
    invokes = set(re.findall(r':?InvokeServer\(([^)]*)\)', content))
    
    # Try finding typical keywords for upgrades, rebirths, passes
    upgrades = set(re.findall(r'p\d+\.([A-Za-z]+Upgrades)', content))
    data_keys = set(re.findall(r'p\d+\.Data\.([A-Za-z]+)', content))

    print("=== Events ===")
    for e in sorted(events): print(e)
    
    print("\n=== Functions ===")
    for f in sorted(functions): print(f)

    print("\n=== Notable Data Keys ===")
    for d in sorted(data_keys): print(d)
    
    print("\n=== Notable Upgrade Trees ===")
    for u in sorted(upgrades): print(u)
    
    print("\n=== FireServer Calls ===")
    for f in sorted(fires): print(f)
    
    print("\n=== InvokeServer Calls ===")
    for i in sorted(invokes): print(i)

if __name__ == "__main__":
    parse_dex()
