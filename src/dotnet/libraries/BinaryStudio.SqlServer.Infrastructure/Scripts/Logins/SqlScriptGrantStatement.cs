using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlGrantStatement))]
    internal sealed class SqlScriptGrantStatement : SqlScriptGdrStatement<SqlGrantStatement>
        {
        #region ctor{IServiceProvider,SqlGrantStatement}
        public SqlScriptGrantStatement(IServiceProvider context,SqlGrantStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }