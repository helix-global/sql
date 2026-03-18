using System;
using System.IO;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SSDTConstraintFormatter : SqlObjectFormatter<ISqlConstraint>
        {
        public static readonly ISqlObjectFormatter<ISqlConstraint> Instance = new SSDTConstraintFormatter();

        #region M:WriteTo(IServiceProvider,ISqlConstraint,TextWriter)
        public override void WriteTo(IServiceProvider provider,ISqlConstraint source,TextWriter target) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            if (target == null) { throw new ArgumentNullException(nameof(target)); }
            if (source is ISqlColumnIdentity ColumnIdentity) { WriteTo(provider,ColumnIdentity,target); }
            else
                {
                throw new NotSupportedException();
                }
            }
        #endregion
        #region M:WriteTo(IServiceProvider,ISqlColumnIdentity,TextWriter)
        private void WriteTo(IServiceProvider provider,ISqlColumnIdentity source,TextWriter target) {
            target.Write("IDENTITY");
            if ((source.Increment != null) && (source.Seed != null)) {
                target.Write($" ({source.Seed}, {source.Increment})");
                }
            else if (source.Seed != null)
                {
                target.Write($" ({source.Seed})");
                }
            }
        #endregion
        }
    }
