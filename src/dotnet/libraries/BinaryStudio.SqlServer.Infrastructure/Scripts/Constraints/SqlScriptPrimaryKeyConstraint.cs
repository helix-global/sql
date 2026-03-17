using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlPrimaryKeyConstraint))]
    internal sealed class SqlScriptPrimaryKeyConstraint : SqlScriptUniqueConstraint<SqlPrimaryKeyConstraint>
        {
        #region ctor{IServiceProvider,SqlPrimaryKeyConstraint}
        public SqlScriptPrimaryKeyConstraint(IServiceProvider context,SqlPrimaryKeyConstraint source)
            : base(context, source)
            {
            }
        #endregion
        }
    }