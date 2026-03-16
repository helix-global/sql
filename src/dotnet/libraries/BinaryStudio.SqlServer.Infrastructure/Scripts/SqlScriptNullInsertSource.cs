using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlNullInsertSource))]
    internal sealed class SqlScriptNullInsertSource : SqlScriptInsertSource<SqlNullInsertSource>
        {
        #region ctor{IServiceProvider,SqlNullInsertSource}
        public SqlScriptNullInsertSource(IServiceProvider context,SqlNullInsertSource source)
            : base(context,source)
            {
            }
        #endregion
        }
    }