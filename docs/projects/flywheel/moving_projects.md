# Moving Projects

We can use lookup and update to move a project to a different group.

This is not possible on the Web UI.

```python
import flywheel #  pip install flywheel-sdk
project = "wpc-8922-spa"
group_orig = "mrrc"
group_new  = "luna"
fw = flywheel.Client(os.getenv("FW_API_KEY"))
project = fw.lookup("{group_orig}/{project}")
project.update({"group": group_new})
```
