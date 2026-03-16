using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlFromClause))]
    internal class SqlScriptFromClause : SqlScriptCodeObject<SqlFromClause>
        {
        #region ctor{IServiceProvider,SqlFromClause}
        public SqlScriptFromClause(IServiceProvider context,SqlFromClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }