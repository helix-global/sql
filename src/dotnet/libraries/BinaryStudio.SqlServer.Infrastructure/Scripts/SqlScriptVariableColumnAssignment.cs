using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlVariableColumnAssignment))]
    internal sealed class SqlScriptVariableColumnAssignment : SqlScriptAssignment<SqlVariableColumnAssignment>
        {
        #region ctor{IServiceProvider,SqlVariableColumnAssignment}
        public SqlScriptVariableColumnAssignment(IServiceProvider context,SqlVariableColumnAssignment source)
            : base(context,source)
            {
            }
        #endregion
        }
    }