using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptForXmlDirective<T> : SqlScriptCodeObject<T>
        where T : SqlForXmlDirective
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptForXmlDirective(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject(typeof(SqlForXmlDirective))]
    internal sealed class SqlScriptForXmlDirective : SqlScriptForXmlDirective<SqlForXmlDirective>
        {
        #region ctor{IServiceProvider,SqlForXmlDirective}
        public SqlScriptForXmlDirective(IServiceProvider context,SqlForXmlDirective source)
            : base(context,source)
            {
            }
        #endregion
        }
    }