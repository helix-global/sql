using System;
using System.IO;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public abstract class SqlObjectFormatter<T>
        {
        #region ctor
        protected SqlObjectFormatter()
            {
            }
        #endregion

        public abstract void WriteTo(T source,TextWriter target);

        #region M:WriteTo(T,{out}String})
        public void WriteTo(T source,out String target) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            var r = new StringBuilder();
            using (var writer = new StringWriter(r)) {
                WriteTo(source,writer);
                }
            target = r.ToString();
            }
        #endregion
        }
    }