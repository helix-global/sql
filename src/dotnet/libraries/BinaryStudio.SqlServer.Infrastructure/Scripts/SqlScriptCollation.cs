using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlCollation))]
    internal sealed class SqlScriptCollation : SqlScriptCodeObject<SqlCollation>
        {
        #region ctor{IServiceProvider,SqlCollation}
        public SqlScriptCollation(IServiceProvider context,SqlCollation source)
            : base(context,source)
            {
            }
        #endregion
        }
    }