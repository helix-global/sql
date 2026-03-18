using System;
using System.IO;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public abstract class SqlObjectFormatter<T> : SqlModelObject,ISqlObjectFormatter<T>
        {
        #region ctor
        protected SqlObjectFormatter()
            {
            }
        #endregion

        public abstract void WriteTo(IServiceProvider provider,T source,TextWriter target);

        #region M:WriteTo(IServiceProvider,T,{out}String})
        public void WriteTo(IServiceProvider provider,T source,out String target) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            var r = new StringBuilder();
            using (var writer = new StringWriter(r)) {
                WriteTo(provider,source,writer);
                }
            target = r.ToString();
            }
        #endregion
        }
    }