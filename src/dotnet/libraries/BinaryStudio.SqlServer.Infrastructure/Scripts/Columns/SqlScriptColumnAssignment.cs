using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlColumnAssignment))]
    internal sealed class SqlScriptColumnAssignment : SqlScriptAssignment<SqlColumnAssignment>
        {
        #region ctor{IServiceProvider,SqlColumnAssignment}
        public SqlScriptColumnAssignment(IServiceProvider context,SqlColumnAssignment source)
            : base(context,source)
            {
            }
        #endregion
        }
    }