using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlMergeStatement))]
    internal sealed class SqlScriptMergeStatement : SqlScriptDmlStatement<SqlMergeStatement>
        {
        #region ctor{IServiceProvider,SqlMergeStatement}
        public SqlScriptMergeStatement(IServiceProvider context,SqlMergeStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }