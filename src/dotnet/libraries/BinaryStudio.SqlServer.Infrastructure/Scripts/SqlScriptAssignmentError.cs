using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlAssignmentError))]
    internal sealed class SqlScriptAssignmentError : SqlScriptAssignment<SqlAssignmentError>
        {
        #region ctor{IServiceProvider,SqlAssignmentError}
        public SqlScriptAssignmentError(IServiceProvider context,SqlAssignmentError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }