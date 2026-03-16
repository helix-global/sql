using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlNullAssignment))]
    internal sealed class SqlScriptNullAssignment : SqlScriptAssignment<SqlNullAssignment>
        {
        #region ctor{IServiceProvider,SqlNullAssignment}
        public SqlScriptNullAssignment(IServiceProvider context,SqlNullAssignment source)
            : base(context,source)
            {
            }
        #endregion
        }
    }