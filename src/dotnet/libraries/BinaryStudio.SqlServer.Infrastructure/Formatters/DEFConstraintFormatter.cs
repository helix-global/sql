using System;
using System.IO;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class DEFConstraintFormatter : SqlObjectFormatter<ISqlConstraint>
        {
        public static readonly ISqlObjectFormatter<ISqlConstraint> Instance = new DEFConstraintFormatter();

        #region M:WriteTo(ISqlConstraint,TextWriter)
        public override void WriteTo(ISqlConstraint source,TextWriter target) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            if (target == null) { throw new ArgumentNullException(nameof(target)); }
            if (source is ISqlColumnIdentity ColumnIdentity) { WriteTo(ColumnIdentity,target); }
            else
                {
                throw new NotSupportedException();
                }
            }
        #endregion
        #region M:WriteTo(ISqlColumnIdentity,TextWriter)
        private void WriteTo(ISqlColumnIdentity source,TextWriter target) {
            target.Write("identity");
            if ((source.Increment != null) && (source.Seed != null)) {
                target.Write($"({source.Seed},{source.Increment})");
                }
            else if (source.Seed != null)
                {
                target.Write($"({source.Seed})");
                }
            }
        #endregion
        }
    }
