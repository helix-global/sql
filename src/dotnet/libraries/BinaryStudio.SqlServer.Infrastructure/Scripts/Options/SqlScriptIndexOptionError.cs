using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlIndexOptionError))]
    internal sealed class SqlScriptIndexOptionError : SqlScriptIndexOption<SqlIndexOptionError>
        {
        #region ctor{IServiceProvider,SqlIndexOptionError}
        public SqlScriptIndexOptionError(IServiceProvider context,SqlIndexOptionError source)
            : base(context,source)
            {
            }
        #endregion
        }
    }