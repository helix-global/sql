using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [UsedImplicitly]
    [SqlScriptObject("Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlConstraint.TypeOnlyConstraint")]
    internal class SqlScriptTypeOnlyConstraint : SqlScriptConstraint<SqlConstraint>
        {
        public static readonly ISqlScriptConstraint Null = new SqlScriptTypeOnlyConstraint(SqlConstraintType.Null);
        public override SqlConstraintType Type { get; }

        #region ctor{IServiceProvider,SqlConstraint}
        public SqlScriptTypeOnlyConstraint(IServiceProvider context,SqlConstraint source)
            : base(context,source)
            {
            Type = (SqlConstraintType)(Int32)source.Type;
            }
        #endregion
        #region ctor{SqlConstraintType}
        private SqlScriptTypeOnlyConstraint(SqlConstraintType type)
            : base(null,null)
            {
            }
        #endregion
        }
    }